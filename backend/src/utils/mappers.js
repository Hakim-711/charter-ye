export function mapSettings(settings) {
  if (!settings) {
    return null;
  }
  return {
    companyNameAr: settings.companyNameAr ?? null,
    companyNameEn: settings.companyNameEn ?? null,
    companySubtitleAr: settings.companySubtitleAr ?? null,
    companySubtitleEn: settings.companySubtitleEn ?? null,
    heroTitleAr: settings.heroTitleAr ?? null,
    heroTitleEn: settings.heroTitleEn ?? null,
    heroDescriptionAr: settings.heroDescriptionAr ?? null,
    heroDescriptionEn: settings.heroDescriptionEn ?? null,
    officePhoneRaw: settings.officePhoneRaw ?? null,
    whatsappRaw: settings.whatsappRaw ?? null,
    email: settings.email ?? null,
    secondaryEmail: settings.secondaryEmail ?? null,
    websiteUrl: settings.websiteUrl ?? null,
    maribAddressAr: settings.maribAddressAr ?? null,
    maribAddressEn: settings.maribAddressEn ?? null,
    adenAddressAr: settings.adenAddressAr ?? null,
    adenAddressEn: settings.adenAddressEn ?? null,
    coverageAr: settings.coverageAr ?? null,
    coverageEn: settings.coverageEn ?? null,
    updatedAt: settings.updatedAt?.toISOString() ?? null,
  };
}

export function mapLead(lead) {
  return {
    id: lead.id,
    createdAtIso: lead.createdAt.toISOString(),
    name: lead.name,
    company: lead.company ?? '',
    phone: lead.phone ?? '',
    email: lead.email ?? '',
    service: lead.service,
    message: lead.message,
    status: lead.status,
  };
}
