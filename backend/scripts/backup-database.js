import 'dotenv/config';

import { prisma } from '../src/config/prisma.js';
import { createDatabaseBackup } from '../src/services/database-backup.js';

createDatabaseBackup()
    .then((file) => console.log(`Backup created: ${file}`))
    .catch((error) => {
      console.error(error);
      process.exitCode = 1;
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
