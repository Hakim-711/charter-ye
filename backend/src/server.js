import { app } from './app.js';
import { initializeDatabase } from './bootstrap/init-database.js';
import { env } from './config/env.js';
import { prisma } from './config/prisma.js';
import { startBackupScheduler } from './services/database-backup.js';

let server;
let stopBackupScheduler = () => {};

async function shutdown(signal) {
  console.log(`Received ${signal}. Shutting down gracefully...`);
  stopBackupScheduler();
  if (!server) {
    await prisma.$disconnect();
    process.exit(0);
    return;
  }

  server.close(async () => {
    await prisma.$disconnect();
    process.exit(0);
  });
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

async function start() {
  try {
    await initializeDatabase();
    server = app.listen(env.port, () => {
      console.log(`Charter backend listening on http://localhost:${env.port}`);
    });
    stopBackupScheduler = startBackupScheduler();
  } catch (error) {
    console.error('Failed to start backend:', error);
    await prisma.$disconnect();
    process.exit(1);
  }
}

start();
