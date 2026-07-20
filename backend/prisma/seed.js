import 'dotenv/config';

import { initializeDatabase } from '../src/bootstrap/init-database.js';
import { env } from '../src/config/env.js';
import { prisma } from '../src/config/prisma.js';

async function main() {
  await initializeDatabase({ resetDefaultAdminPassword: true });
  console.log(`Seed completed. Admin username: ${env.adminDefaultUsername}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
