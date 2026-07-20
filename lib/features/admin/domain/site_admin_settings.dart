class SiteAdminSettings {
  const SiteAdminSettings({
    this.companyNameAr,
    this.companyNameEn,
    this.companySubtitleAr,
    this.companySubtitleEn,
    this.heroTitleAr,
    this.heroTitleEn,
    this.heroDescriptionAr,
    this.heroDescriptionEn,
    this.officePhoneRaw,
    this.whatsappRaw,
    this.email,
    this.secondaryEmail,
    this.websiteUrl,
    this.maribAddressAr,
    this.maribAddressEn,
    this.adenAddressAr,
    this.adenAddressEn,
    this.coverageAr,
    this.coverageEn,
  });

  final String? companyNameAr;
  final String? companyNameEn;
  final String? companySubtitleAr;
  final String? companySubtitleEn;
  final String? heroTitleAr;
  final String? heroTitleEn;
  final String? heroDescriptionAr;
  final String? heroDescriptionEn;
  final String? officePhoneRaw;
  final String? whatsappRaw;
  final String? email;
  final String? secondaryEmail;
  final String? websiteUrl;
  final String? maribAddressAr;
  final String? maribAddressEn;
  final String? adenAddressAr;
  final String? adenAddressEn;
  final String? coverageAr;
  final String? coverageEn;

  SiteAdminSettings copyWith({
    String? companyNameAr,
    String? companyNameEn,
    String? companySubtitleAr,
    String? companySubtitleEn,
    String? heroTitleAr,
    String? heroTitleEn,
    String? heroDescriptionAr,
    String? heroDescriptionEn,
    String? officePhoneRaw,
    String? whatsappRaw,
    String? email,
    String? secondaryEmail,
    String? websiteUrl,
    String? maribAddressAr,
    String? maribAddressEn,
    String? adenAddressAr,
    String? adenAddressEn,
    String? coverageAr,
    String? coverageEn,
  }) {
    return SiteAdminSettings(
      companyNameAr: companyNameAr ?? this.companyNameAr,
      companyNameEn: companyNameEn ?? this.companyNameEn,
      companySubtitleAr: companySubtitleAr ?? this.companySubtitleAr,
      companySubtitleEn: companySubtitleEn ?? this.companySubtitleEn,
      heroTitleAr: heroTitleAr ?? this.heroTitleAr,
      heroTitleEn: heroTitleEn ?? this.heroTitleEn,
      heroDescriptionAr: heroDescriptionAr ?? this.heroDescriptionAr,
      heroDescriptionEn: heroDescriptionEn ?? this.heroDescriptionEn,
      officePhoneRaw: officePhoneRaw ?? this.officePhoneRaw,
      whatsappRaw: whatsappRaw ?? this.whatsappRaw,
      email: email ?? this.email,
      secondaryEmail: secondaryEmail ?? this.secondaryEmail,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      maribAddressAr: maribAddressAr ?? this.maribAddressAr,
      maribAddressEn: maribAddressEn ?? this.maribAddressEn,
      adenAddressAr: adenAddressAr ?? this.adenAddressAr,
      adenAddressEn: adenAddressEn ?? this.adenAddressEn,
      coverageAr: coverageAr ?? this.coverageAr,
      coverageEn: coverageEn ?? this.coverageEn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyNameAr': companyNameAr,
      'companyNameEn': companyNameEn,
      'companySubtitleAr': companySubtitleAr,
      'companySubtitleEn': companySubtitleEn,
      'heroTitleAr': heroTitleAr,
      'heroTitleEn': heroTitleEn,
      'heroDescriptionAr': heroDescriptionAr,
      'heroDescriptionEn': heroDescriptionEn,
      'officePhoneRaw': officePhoneRaw,
      'whatsappRaw': whatsappRaw,
      'email': email,
      'secondaryEmail': secondaryEmail,
      'websiteUrl': websiteUrl,
      'maribAddressAr': maribAddressAr,
      'maribAddressEn': maribAddressEn,
      'adenAddressAr': adenAddressAr,
      'adenAddressEn': adenAddressEn,
      'coverageAr': coverageAr,
      'coverageEn': coverageEn,
    };
  }

  factory SiteAdminSettings.fromJson(Map<String, dynamic> json) {
    return SiteAdminSettings(
      companyNameAr: json['companyNameAr'] as String?,
      companyNameEn: json['companyNameEn'] as String?,
      companySubtitleAr: json['companySubtitleAr'] as String?,
      companySubtitleEn: json['companySubtitleEn'] as String?,
      heroTitleAr: json['heroTitleAr'] as String?,
      heroTitleEn: json['heroTitleEn'] as String?,
      heroDescriptionAr: json['heroDescriptionAr'] as String?,
      heroDescriptionEn: json['heroDescriptionEn'] as String?,
      officePhoneRaw: json['officePhoneRaw'] as String?,
      whatsappRaw: json['whatsappRaw'] as String?,
      email: json['email'] as String?,
      secondaryEmail: json['secondaryEmail'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      maribAddressAr: json['maribAddressAr'] as String?,
      maribAddressEn: json['maribAddressEn'] as String?,
      adenAddressAr: json['adenAddressAr'] as String?,
      adenAddressEn: json['adenAddressEn'] as String?,
      coverageAr: json['coverageAr'] as String?,
      coverageEn: json['coverageEn'] as String?,
    );
  }
}
