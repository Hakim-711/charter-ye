import express from 'express';
import { z } from 'zod';

import { prisma } from '../config/prisma.js';
import { requireAuth } from '../middleware/auth.js';
import { mapLead, mapSettings } from '../utils/mappers.js';

const router = express.Router();

const nullableText = z.union([z.string().trim().max(4000), z.null()]).optional();
const nullableShortText = z.union([z.string().trim().max(240), z.null()]).optional();

const settingsSchema = z.object({
  companyNameAr: nullableShortText,
  companyNameEn: nullableShortText,
  companySubtitleAr: nullableShortText,
  companySubtitleEn: nullableShortText,
  heroTitleAr: nullableShortText,
  heroTitleEn: nullableShortText,
  heroDescriptionAr: nullableText,
  heroDescriptionEn: nullableText,
  officePhoneRaw: nullableShortText,
  whatsappRaw: nullableShortText,
  email: nullableShortText,
  secondaryEmail: nullableShortText,
  websiteUrl: nullableShortText,
  maribAddressAr: nullableText,
  maribAddressEn: nullableText,
  adenAddressAr: nullableText,
  adenAddressEn: nullableText,
  coverageAr: nullableText,
  coverageEn: nullableText,
});

const replaceLeadSchema = z.object({
  id: z.string().min(1),
  createdAtIso: z.string().datetime(),
  name: z.string().trim().min(1).max(120),
  company: z.string().trim().max(120).optional(),
  phone: z.string().trim().max(30).optional().default(''),
  email: z
      .string()
      .trim()
      .max(180)
      .refine(
          (value) => value === '' || z.string().email().safeParse(value).success,
          'Invalid email address.',
      )
      .optional()
      .default(''),
  service: z.string().trim().min(1).max(120),
  message: z.string().trim().max(4000),
  status: z.enum(['newLead', 'contacted', 'closed']),
});

const updateLeadStatusSchema = z.object({
  status: z.enum(['newLead', 'contacted', 'closed']),
});

router.use(requireAuth);

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

router.put('/settings', async (req, res) => {
  const parsed = settingsSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      code: 'VALIDATION_ERROR',
      message: 'Invalid settings payload.',
    });
  }

  const data = Object.fromEntries(
      Object.entries(parsed.data).map(([key, value]) => [
        key,
        typeof value === 'string' ? value.trim() : value,
      ]),
  );

  const updated = await prisma.siteSettings.upsert({
    where: { id: 1 },
    update: data,
    create: { id: 1, ...data },
  });

  return res.status(200).json({
    data: mapSettings(updated),
  });
});

router.delete('/settings', async (req, res) => {
  const cleared = await prisma.siteSettings.upsert({
    where: { id: 1 },
    update: {
      companyNameAr: null,
      companyNameEn: null,
      companySubtitleAr: null,
      companySubtitleEn: null,
      heroTitleAr: null,
      heroTitleEn: null,
      heroDescriptionAr: null,
      heroDescriptionEn: null,
      officePhoneRaw: null,
      whatsappRaw: null,
      email: null,
      secondaryEmail: null,
      websiteUrl: null,
      maribAddressAr: null,
      maribAddressEn: null,
      adenAddressAr: null,
      adenAddressEn: null,
      coverageAr: null,
      coverageEn: null,
    },
    create: { id: 1 },
  });

  return res.status(200).json({
    data: mapSettings(cleared),
  });
});

router.get('/leads', async (req, res) => {
  const leads = await prisma.lead.findMany({
    orderBy: { createdAt: 'desc' },
  });
  return res.status(200).json({
    data: leads.map(mapLead),
  });
});

router.put('/leads', async (req, res) => {
  if (!Array.isArray(req.body)) {
    return res.status(400).json({
      code: 'VALIDATION_ERROR',
      message: 'Payload must be an array.',
    });
  }

  const parsedLeads = [];
  for (const item of req.body) {
    const parsed = replaceLeadSchema.safeParse(item);
    if (!parsed.success) {
      return res.status(400).json({
        code: 'VALIDATION_ERROR',
        message: 'Invalid lead payload.',
      });
    }
    parsedLeads.push(parsed.data);
  }

  await prisma.$transaction(async (tx) => {
    await tx.lead.deleteMany();
    if (parsedLeads.length > 0) {
      await tx.lead.createMany({
        data: parsedLeads.map((lead) => ({
          id: lead.id,
          createdAt: new Date(lead.createdAtIso),
          name: lead.name,
          company: lead.company || null,
          phone: lead.phone,
          email: lead.email.toLowerCase(),
          service: lead.service,
          message: lead.message,
          status: lead.status,
        })),
      });
    }
  });

  const leads = await prisma.lead.findMany({
    orderBy: { createdAt: 'desc' },
  });
  return res.status(200).json({
    data: leads.map(mapLead),
  });
});

router.patch('/leads/:id/status', async (req, res) => {
  const parsed = updateLeadStatusSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      code: 'VALIDATION_ERROR',
      message: 'Invalid status payload.',
    });
  }

  const existing = await prisma.lead.findUnique({
    where: { id: req.params.id },
  });
  if (!existing) {
    return res.status(404).json({
      code: 'LEAD_NOT_FOUND',
      message: 'Lead not found.',
    });
  }

  const updated = await prisma.lead.update({
    where: { id: req.params.id },
    data: {
      status: parsed.data.status,
    },
  });
  return res.status(200).json({
    data: mapLead(updated),
  });
});

router.delete('/leads/:id', async (req, res) => {
  const existing = await prisma.lead.findUnique({
    where: { id: req.params.id },
  });
  if (!existing) {
    return res.status(404).json({
      code: 'LEAD_NOT_FOUND',
      message: 'Lead not found.',
    });
  }

  await prisma.lead.delete({
    where: { id: req.params.id },
  });
  return res.status(204).send();
});

router.delete('/leads', async (req, res) => {
  await prisma.lead.deleteMany();
  return res.status(204).send();
});

export { router as adminRoutes };
