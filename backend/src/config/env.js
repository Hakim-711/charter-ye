import dotenv from 'dotenv';

dotenv.config();

const defaultJwtSecret = 'change_this_secret_in_production';
const defaultAdminPassword = 'ChangeMe@12345';

function parsePositiveInt(value, fallback) {
  const parsed = Number.parseInt(value ?? '', 10);
  if (Number.isNaN(parsed) || parsed <= 0) {
    return fallback;
  }
  return parsed;
}

function parseAllowedOrigins(value) {
  if (!value || !value.trim()) {
    return ['*'];
  }
  return value
      .split(',')
      .map((item) => item.trim())
      .filter((item) => item.length > 0);
}

export const env = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parsePositiveInt(process.env.PORT, 4000),
  databaseUrl: process.env.DATABASE_URL || 'file:./dev.db',
  jwtSecret: process.env.JWT_SECRET || defaultJwtSecret,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '8h',
  authMaxFailedAttempts: parsePositiveInt(process.env.AUTH_MAX_FAILED_ATTEMPTS, 5),
  authLockoutMinutes: parsePositiveInt(process.env.AUTH_LOCKOUT_MINUTES, 10),
  adminDefaultUsername: (process.env.ADMIN_DEFAULT_USERNAME || 'admin').trim(),
  adminDefaultPassword: (
    process.env.ADMIN_DEFAULT_PASSWORD || defaultAdminPassword
  ).trim(),
  allowedOrigins: parseAllowedOrigins(process.env.ALLOWED_ORIGINS),
};

if (env.nodeEnv === 'production') {
  if (env.jwtSecret === defaultJwtSecret) {
    throw new Error('JWT_SECRET must be set to a secure value in production.');
  }
  if (env.adminDefaultPassword === defaultAdminPassword) {
    throw new Error(
      'ADMIN_DEFAULT_PASSWORD must be set to a secure value in production.',
    );
  }
}
