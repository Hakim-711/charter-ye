import bcrypt from 'bcryptjs';
import { mkdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { env } from '../config/env.js';
import { prisma } from '../config/prisma.js';

const schemaStatements = [
  `
    CREATE TABLE IF NOT EXISTS "AdminUser" (
      "id" TEXT NOT NULL PRIMARY KEY,
      "username" TEXT NOT NULL,
      "passwordHash" TEXT NOT NULL,
      "fullName" TEXT,
      "isActive" BOOLEAN NOT NULL DEFAULT 1,
      "failedAttempts" INTEGER NOT NULL DEFAULT 0,
      "lockoutUntil" DATETIME,
      "tokenVersion" INTEGER NOT NULL DEFAULT 0,
      "lastLoginAt" DATETIME,
      "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `,
  'CREATE UNIQUE INDEX IF NOT EXISTS "AdminUser_username_key" ON "AdminUser"("username");',
  `
    CREATE TABLE IF NOT EXISTS "SiteSettings" (
      "id" INTEGER NOT NULL PRIMARY KEY,
      "companyNameAr" TEXT,
      "companyNameEn" TEXT,
      "companySubtitleAr" TEXT,
      "companySubtitleEn" TEXT,
      "heroTitleAr" TEXT,
      "heroTitleEn" TEXT,
      "heroDescriptionAr" TEXT,
      "heroDescriptionEn" TEXT,
      "officePhoneRaw" TEXT,
      "whatsappRaw" TEXT,
      "email" TEXT,
      "secondaryEmail" TEXT,
      "websiteUrl" TEXT,
      "maribAddressAr" TEXT,
      "maribAddressEn" TEXT,
      "adenAddressAr" TEXT,
      "adenAddressEn" TEXT,
      "coverageAr" TEXT,
      "coverageEn" TEXT,
      "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `,
  `
    CREATE TABLE IF NOT EXISTS "Lead" (
      "id" TEXT NOT NULL PRIMARY KEY,
      "name" TEXT NOT NULL,
      "company" TEXT,
      "phone" TEXT NOT NULL DEFAULT '',
      "email" TEXT NOT NULL DEFAULT '',
      "service" TEXT NOT NULL,
      "message" TEXT NOT NULL,
      "status" TEXT NOT NULL DEFAULT 'newLead',
      "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      "updatedAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `,
  'CREATE INDEX IF NOT EXISTS "Lead_createdAt_idx" ON "Lead"("createdAt");',
];

async function ensureSchema() {
  for (const statement of schemaStatements) {
    await prisma.$executeRawUnsafe(statement);
  }
}

async function ensureSiteSettingsColumns() {
  const columns = await prisma.$queryRawUnsafe('PRAGMA table_info("SiteSettings");');
  const existing = new Set(columns.map((column) => column.name));
  const requiredColumns = [
    ['secondaryEmail', 'TEXT'],
    ['adenAddressAr', 'TEXT'],
    ['adenAddressEn', 'TEXT'],
  ];

  for (const [column, type] of requiredColumns) {
    if (!existing.has(column)) {
      await prisma.$executeRawUnsafe(
          `ALTER TABLE "SiteSettings" ADD COLUMN "${column}" ${type};`,
      );
    }
  }
}

async function ensureAdminUserColumns() {
  const columns = await prisma.$queryRawUnsafe('PRAGMA table_info("AdminUser");');
  const existing = new Set(columns.map((column) => column.name));
  if (!existing.has('tokenVersion')) {
    await prisma.$executeRawUnsafe(
        'ALTER TABLE "AdminUser" ADD COLUMN "tokenVersion" INTEGER NOT NULL DEFAULT 0;',
    );
  }
}

async function ensureLeadColumns() {
  const columns = await prisma.$queryRawUnsafe('PRAGMA table_info("Lead");');
  const existing = new Set(columns.map((column) => column.name));
  const requiredColumns = [
    ['phone', "TEXT NOT NULL DEFAULT ''"],
    ['email', "TEXT NOT NULL DEFAULT ''"],
  ];

  for (const [column, type] of requiredColumns) {
    if (!existing.has(column)) {
      await prisma.$executeRawUnsafe(
          `ALTER TABLE "Lead" ADD COLUMN "${column}" ${type};`,
      );
    }
  }
}

async function ensureSqliteDirectory() {
  const databaseUrl = env.databaseUrl.trim();
  if (!databaseUrl.startsWith('file:')) {
    return;
  }

  const sqlitePath = databaseUrl.slice('file:'.length).trim();
  if (!sqlitePath || sqlitePath === ':memory:') {
    return;
  }

  if (path.isAbsolute(sqlitePath)) {
    const directory = path.dirname(sqlitePath);
    if (directory) {
      await mkdir(directory, { recursive: true });
    }
    return;
  }

  const schemaDir = path.dirname(
    fileURLToPath(new URL('../../prisma/schema.prisma', import.meta.url)),
  );
  const directories = new Set([
    path.dirname(path.resolve(process.cwd(), sqlitePath)),
    path.dirname(path.resolve(schemaDir, sqlitePath)),
  ]);

  for (const directory of directories) {
    if (directory && directory !== '.') {
      await mkdir(directory, { recursive: true });
    }
  }
}

async function ensureDefaultRows() {
  await prisma.siteSettings.upsert({
    where: { id: 1 },
    update: {},
    create: { id: 1 },
  });
}

async function ensureDefaultAdmin({ resetPassword }) {
  const username = env.adminDefaultUsername;
  const password = env.adminDefaultPassword;
  if (!username || !password) {
    console.warn(
      'Skipping default admin bootstrap: ADMIN_DEFAULT_USERNAME or ADMIN_DEFAULT_PASSWORD is empty.',
    );
    return;
  }

  const existing = await prisma.adminUser.findUnique({
    where: { username },
  });

  if (!existing) {
    const passwordHash = await bcrypt.hash(password, 12);
    await prisma.adminUser.create({
      data: {
        username,
        passwordHash,
        isActive: true,
      },
    });
    console.log(`Default admin created: ${username}`);
    return;
  }

  if (resetPassword) {
    const passwordHash = await bcrypt.hash(password, 12);
    await prisma.adminUser.update({
      where: { id: existing.id },
      data: {
        passwordHash,
        isActive: true,
        failedAttempts: 0,
        lockoutUntil: null,
        tokenVersion: { increment: 1 },
      },
    });
    console.log(`Default admin password reset: ${username}`);
  }
}

export async function initializeDatabase({ resetDefaultAdminPassword = false } = {}) {
  await ensureSqliteDirectory();
  await ensureSchema();
  await ensureAdminUserColumns();
  await ensureSiteSettingsColumns();
  await ensureLeadColumns();
  await ensureDefaultRows();
  await ensureDefaultAdmin({ resetPassword: resetDefaultAdminPassword });
}
