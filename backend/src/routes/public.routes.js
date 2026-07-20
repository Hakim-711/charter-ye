import express from 'express';
import { z } from 'zod';

import { prisma } from '../config/prisma.js';
import { mapLead, mapSettings } from '../utils/mappers.js';
import { notifyNewLead } from '../services/lead-notification.js';

const router = express.Router();

const submitLeadSchema = z.object({
  name: z.string().trim().min(2).max(120),
  company: z.string().trim().max(120).optional(),
  phone: z.string().trim().min(7).max(30),
  email: z.string().trim().email().max(180),
  service: z.string().trim().min(2).max(120),
  message: z.string().trim().min(10).max(4000),
  website: z.string().trim().max(0).optional(),
});

router.get('/settings', async (req, res) => {
  const settings = await prisma.siteSettings.upsert({
    where: { id: 1 },
    update: {},
    create: { id: 1 },
  });
  return res.status(200).json({
    data: mapSettings(settings),
  });
});

router.post('/leads', async (req, res) => {
  const parsed = submitLeadSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      code: 'VALIDATION_ERROR',
      message: 'Invalid lead payload.',
    });
  }

  const lead = await prisma.lead.create({
    data: {
      name: parsed.data.name,
      company: parsed.data.company || null,
      phone: parsed.data.phone,
      email: parsed.data.email.toLowerCase(),
      service: parsed.data.service,
      message: parsed.data.message,
      status: 'newLead',
    },
  });

  notifyNewLead(lead).catch((error) => {
    console.error('[LEAD_NOTIFICATION_ERROR]', error);
  });

  return res.status(201).json({
    data: mapLead(lead),
  });
});

export { router as publicRoutes };
