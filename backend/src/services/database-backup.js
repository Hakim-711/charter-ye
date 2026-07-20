import { mkdir, readdir, rm } from 'node:fs/promises';
import path from 'node:path';

import { env } from '../config/env.js';
import { prisma } from '../config/prisma.js';

const backupPrefix = 'charter-';
const backupSuffix = '.db';

function getDatabasePath() {
  const url = env.databaseUrl.trim();
  if (!url.startsWith('file:')) {
    throw new Error('Automated backups currently support SQLite file databases only.');
  }
  const filePath = url.slice('file:'.length).trim();
  if (!filePath || filePath === ':memory:') {
    throw new Error('A persistent SQLite database is required for backups.');
  }
  return path.isAbsolute(filePath)
    ? filePath
    : path.resolve(process.cwd(), filePath);
}

function getBackupDirectory() {
  if (env.backupDirectory) {
    return path.resolve(env.backupDirectory);
  }
  return path.join(path.dirname(getDatabasePath()), 'backups');
}

function backupFilename(date = new Date()) {
  const stamp = date.toISOString().replaceAll(':', '-').replaceAll('.', '-');
  return `${backupPrefix}${stamp}${backupSuffix}`;
}

async function pruneBackups(directory) {
  const files = (await readdir(directory))
      .filter((name) => name.startsWith(backupPrefix) && name.endsWith(backupSuffix))
      .sort()
      .reverse();
  const expired = files.slice(env.backupRetentionCount);
  await Promise.all(
      expired.map((name) => rm(path.join(directory, name), { force: true })),
  );
}

export async function createDatabaseBackup() {
  const directory = getBackupDirectory();
  await mkdir(directory, { recursive: true });
  const destination = path.join(directory, backupFilename());
  const escaped = destination.replaceAll("'", "''");
  await prisma.$executeRawUnsafe(`VACUUM INTO '${escaped}';`);
  await pruneBackups(directory);
  return destination;
}

export function startBackupScheduler() {
  if (!env.backupEnabled) {
    return () => {};
  }

  const run = () => {
    createDatabaseBackup()
        .then((file) => console.log(`Database backup created: ${file}`))
        .catch((error) => console.error('[DATABASE_BACKUP_ERROR]', error));
  };
  const initialTimer = setTimeout(run, 15_000);
  const interval = setInterval(run, env.backupIntervalHours * 60 * 60 * 1000);
  initialTimer.unref();
  interval.unref();

  return () => {
    clearTimeout(initialTimer);
    clearInterval(interval);
  };
}
