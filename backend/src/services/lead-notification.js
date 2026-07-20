import nodemailer from 'nodemailer';

import { env } from '../config/env.js';

let transporter;

function isConfigured() {
  return Boolean(
      env.smtpHost &&
      env.smtpUser &&
      env.smtpPassword &&
      env.leadNotificationTo,
  );
}

function escapeHtml(value) {
  return String(value)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
}

function getTransporter() {
  transporter ??= nodemailer.createTransport({
    host: env.smtpHost,
    port: env.smtpPort,
    secure: env.smtpSecure,
    auth: {
      user: env.smtpUser,
      pass: env.smtpPassword,
    },
  });
  return transporter;
}

export async function notifyNewLead(lead) {
  if (!isConfigured()) {
    return { delivered: false, reason: 'not_configured' };
  }

  const from = env.leadNotificationFrom || env.smtpUser;
  const subject = `New Charter request: ${lead.service}`;
  const text = [
    `Name: ${lead.name}`,
    `Company: ${lead.company || '-'}`,
    `Phone: ${lead.phone}`,
    `Email: ${lead.email}`,
    `Service: ${lead.service}`,
    '',
    lead.message,
  ].join('\n');
  const html = `
    <h2>New Charter service request</h2>
    <p><strong>Name:</strong> ${escapeHtml(lead.name)}</p>
    <p><strong>Company:</strong> ${escapeHtml(lead.company || '-')}</p>
    <p><strong>Phone:</strong> ${escapeHtml(lead.phone)}</p>
    <p><strong>Email:</strong> ${escapeHtml(lead.email)}</p>
    <p><strong>Service:</strong> ${escapeHtml(lead.service)}</p>
    <p><strong>Message:</strong></p>
    <p>${escapeHtml(lead.message).replaceAll('\n', '<br>')}</p>
  `;

  await getTransporter().sendMail({
    from,
    to: env.leadNotificationTo,
    replyTo: lead.email,
    subject,
    text,
    html,
  });
  return { delivered: true };
}
