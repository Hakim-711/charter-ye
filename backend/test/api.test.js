import assert from 'node:assert/strict';
import { mkdtemp, readdir, rm } from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';

import request from 'supertest';

const tempDirectory = await mkdtemp(path.join(os.tmpdir(), 'charter-api-test-'));
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = `file:${path.join(tempDirectory, 'test.db')}`;
process.env.JWT_SECRET = 'test-only-jwt-secret';
process.env.ADMIN_DEFAULT_USERNAME = 'admin';
process.env.ADMIN_DEFAULT_PASSWORD = 'TestAdmin123!';
process.env.BACKUP_ENABLED = 'false';

const { app } = await import('../src/app.js');
const { initializeDatabase } = await import('../src/bootstrap/init-database.js');
const { prisma } = await import('../src/config/prisma.js');
const { createDatabaseBackup } = await import(
    '../src/services/database-backup.js'
);

await initializeDatabase({ resetDefaultAdminPassword: true });

test.after(async () => {
  await prisma.$disconnect();
  await rm(tempDirectory, { recursive: true, force: true });
});

test('health endpoint reports service availability', async () => {
  const response = await request(app).get('/api/health').expect(200);
  assert.equal(response.body.status, 'ok');
});

test('lead submission requires contact details', async () => {
  const response = await request(app)
      .post('/api/public/leads')
      .send({
        name: 'Potential Client',
        company: 'Example Co',
        service: 'Logistics',
        message: 'We need a detailed logistics proposal.',
      })
      .expect(400);
  assert.equal(response.body.code, 'VALIDATION_ERROR');
});

test('lead submission stores phone and normalized email', async () => {
  const response = await request(app)
      .post('/api/public/leads')
      .send({
        name: 'Potential Client',
        company: 'Example Co',
        phone: '+967 774 863 677',
        email: 'CLIENT@EXAMPLE.COM',
        service: 'Logistics',
        message: 'We need a detailed logistics proposal.',
        website: '',
      })
      .expect(201);
  assert.equal(response.body.data.phone, '+967 774 863 677');
  assert.equal(response.body.data.email, 'client@example.com');
});

test('admin login can read the protected lead inbox', async () => {
  const login = await request(app)
      .post('/api/auth/login')
      .send({ username: 'admin', password: 'TestAdmin123!' })
      .expect(200);
  const token = login.body.data.token;
  assert.ok(token);

  const inbox = await request(app)
      .get('/api/admin/leads')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
  assert.equal(inbox.body.data.length, 1);
  assert.equal(inbox.body.data[0].email, 'client@example.com');
});

test('logout invalidates the issued token', async () => {
  const login = await request(app)
      .post('/api/auth/login')
      .send({ username: 'admin', password: 'TestAdmin123!' })
      .expect(200);
  const token = login.body.data.token;

  await request(app)
      .post('/api/auth/logout')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
  await request(app)
      .get('/api/admin/leads')
      .set('Authorization', `Bearer ${token}`)
      .expect(401);
});

test('SQLite backup creates a restorable database file', async () => {
  const backup = await createDatabaseBackup();
  assert.ok(backup.endsWith('.db'));
  const files = await readdir(path.dirname(backup));
  assert.ok(files.includes(path.basename(backup)));
});
