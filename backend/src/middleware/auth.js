import jwt from 'jsonwebtoken';

import { env } from '../config/env.js';

export function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  if (!header.startsWith('Bearer ')) {
    return res.status(401).json({
      code: 'AUTH_REQUIRED',
      message: 'Authentication required.',
    });
  }

  const token = header.slice(7).trim();
  if (!token) {
    return res.status(401).json({
      code: 'AUTH_REQUIRED',
      message: 'Authentication required.',
    });
  }

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.auth = payload;
    return next();
  } catch (_) {
    return res.status(401).json({
      code: 'AUTH_INVALID',
      message: 'Invalid or expired token.',
    });
  }
}
