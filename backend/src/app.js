import cors from 'cors';
import express from 'express';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import morgan from 'morgan';

import { env } from './config/env.js';
import { adminRoutes } from './routes/admin.routes.js';
import { authRoutes } from './routes/auth.routes.js';
import { publicRoutes } from './routes/public.routes.js';
import { errorHandler, notFoundHandler } from './middleware/error-handler.js';

const app = express();

const corsOptions = {
  origin(origin, callback) {
    if (!origin || env.allowedOrigins.includes('*')) {
      callback(null, true);
      return;
    }
    const allowed = env.allowedOrigins.includes(origin);
    callback(allowed ? null : new Error('Not allowed by CORS'), allowed);
  },
};

app.use(helmet());
app.use(cors(corsOptions));
app.use(express.json({ limit: '2mb' }));
app.use(morgan(env.nodeEnv === 'production' ? 'combined' : 'dev'));

const publicLeadLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    code: 'RATE_LIMITED',
    message: 'Too many requests from this IP. Please try again later.',
  },
});

app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});

app.use('/api/public/leads', publicLeadLimiter);
app.use('/api/public', publicRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);

app.use(notFoundHandler);
app.use(errorHandler);

export { app };
