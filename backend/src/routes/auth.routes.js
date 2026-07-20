import bcrypt from 'bcryptjs';
import express from 'express';
import jwt from 'jsonwebtoken';
import { z } from 'zod';

import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import { requireAuth } from '../middleware/auth.js';
import { isStrongPassword } from '../utils/password-policy.js';

const router = express.Router();

const loginSchema = z.object({
  username: z.string().min(2).max(80),
  password: z.string().min(1).max(256),
});

const changePasswordSchema = z.object({
  currentPassword: z.string().min(1).max(256),
  newPassword: z.string().min(10).max(256),
});

function signToken(adminUser) {
  return jwt.sign(
      {
        sub: adminUser.id,
        username: adminUser.username,
      },
      env.jwtSecret,
      { expiresIn: env.jwtExpiresIn },
  );
}

function mapAdminUser(adminUser) {
  return {
    id: adminUser.id,
    username: adminUser.username,
    fullName: adminUser.fullName ?? '',
    lastLoginAt: adminUser.lastLoginAt?.toISOString() ?? null,
  };
}

router.post('/login', async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      code: 'VALIDATION_ERROR',
      message: 'Invalid login payload.',
    });
  }

  const username = parsed.data.username.trim();
  const password = parsed.data.password;

  const user = await prisma.adminUser.findUnique({
    where: { username },
  });

  if (!user || !user.isActive) {
    return res.status(401).json({
      code: 'AUTH_INVALID_CREDENTIALS',
      message: 'Invalid username or password.',
    });
  }

  const now = new Date();
  if (user.lockoutUntil && user.lockoutUntil > now) {
    const retrySeconds = Math.max(
        1,
        Math.ceil((user.lockoutUntil.getTime() - now.getTime()) / 1000),
    );
    return res.status(423).json({
      code: 'AUTH_LOCKED',
      message: 'Too many failed attempts. Try later.',
      retrySeconds,
    });
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    const attempts = user.failedAttempts + 1;
    if (attempts >= env.authMaxFailedAttempts) {
      const lockoutUntil = new Date(
          now.getTime() + env.authLockoutMinutes * 60 * 1000,
      );
      await prisma.adminUser.update({
        where: { id: user.id },
        data: {
          failedAttempts: 0,
          lockoutUntil,
        },
      });
      return res.status(423).json({
        code: 'AUTH_LOCKED',
        message: 'Too many failed attempts. Try later.',
        retrySeconds: env.authLockoutMinutes * 60,
      });
    }

    await prisma.adminUser.update({
      where: { id: user.id },
      data: {
        failedAttempts: attempts,
        lockoutUntil: null,
      },
    });
    return res.status(401).json({
      code: 'AUTH_INVALID_CREDENTIALS',
      message: 'Invalid username or password.',
    });
  }

  const updatedUser = await prisma.adminUser.update({
    where: { id: user.id },
    data: {
      failedAttempts: 0,
      lockoutUntil: null,
      lastLoginAt: now,
    },
  });

  const token = signToken(updatedUser);
  return res.status(200).json({
    data: {
      token,
      admin: mapAdminUser(updatedUser),
    },
  });
});

router.get('/me', requireAuth, async (req, res) => {
  const userId = req.auth?.sub;
  if (!userId) {
    return res.status(401).json({
      code: 'AUTH_REQUIRED',
      message: 'Authentication required.',
    });
  }

  const user = await prisma.adminUser.findUnique({
    where: { id: userId },
  });
  if (!user || !user.isActive) {
    return res.status(401).json({
      code: 'AUTH_INVALID',
      message: 'Invalid session.',
    });
  }

  return res.status(200).json({
    data: mapAdminUser(user),
  });
});

router.post('/change-password', requireAuth, async (req, res) => {
  const userId = req.auth?.sub;
  if (!userId) {
    return res.status(401).json({
      code: 'AUTH_REQUIRED',
      message: 'Authentication required.',
    });
  }

  const parsed = changePasswordSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      code: 'VALIDATION_ERROR',
      message: 'Invalid payload.',
    });
  }

  const { currentPassword, newPassword } = parsed.data;
  if (!isStrongPassword(newPassword)) {
    return res.status(400).json({
      code: 'PASSWORD_WEAK',
      message: 'Password does not meet strength policy.',
    });
  }

  const user = await prisma.adminUser.findUnique({ where: { id: userId } });
  if (!user || !user.isActive) {
    return res.status(401).json({
      code: 'AUTH_INVALID',
      message: 'Invalid session.',
    });
  }

  const validCurrent = await bcrypt.compare(currentPassword, user.passwordHash);
  if (!validCurrent) {
    return res.status(401).json({
      code: 'PASSWORD_CURRENT_INVALID',
      message: 'Current password is incorrect.',
    });
  }

  const nextHash = await bcrypt.hash(newPassword, 12);
  await prisma.adminUser.update({
    where: { id: user.id },
    data: {
      passwordHash: nextHash,
      failedAttempts: 0,
      lockoutUntil: null,
    },
  });

  return res.status(200).json({
    data: { updated: true },
  });
});

router.post('/logout', requireAuth, async (req, res) => {
  return res.status(200).json({
    data: { loggedOut: true },
  });
});

export { router as authRoutes };
