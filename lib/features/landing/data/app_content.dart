import 'package:flutter/material.dart';

import '../../admin/domain/site_admin_settings.dart';
import '../domain/landing_models.dart';

class AppContent {
  AppContent({required this.language, this.overrides});

  final Language language;
  final SiteAdminSettings? overrides;

  static AppContent of(Language language, {SiteAdminSettings? overrides}) =>
      AppContent(language: language, overrides: overrides);

  bool get isArabic => language == Language.ar;

  static const Map<String, String> _arabicDigits = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  static const Map<String, String> _latinToArabicDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };

  String _resolveText(String fallback, String? override) {
    final value = override?.trim();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value;
  }

  BilingualText _resolveBilingual({
    required BilingualText fallback,
    String? arOverride,
    String? enOverride,
  }) {
    return BilingualText(
      ar: _resolveText(fallback.ar, arOverride),
      en: _resolveText(fallback.en, enOverride),
    );
  }

  String _normalizePhoneRaw(String? input, {required String fallback}) {
    final raw = (input ?? '')
        .split('')
        .map((ch) => _arabicDigits[ch] ?? ch)
        .join();
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return fallback;
    }
    return digitsOnly;
  }

  String _formatPhoneForDisplay(String raw) {
    if (raw.length == 12 && raw.startsWith('967')) {
      final country = raw.substring(0, 3);
      final p1 = raw.substring(3, 6);
      final p2 = raw.substring(6, 9);
      final p3 = raw.substring(9, 12);
      final english = '+$country $p1 $p2 $p3';
      if (!isArabic) {
        return english;
      }
      return english
          .split('')
          .map((ch) => _latinToArabicDigits[ch] ?? ch)
          .join();
    }

    final normalized = '+$raw';
    if (!isArabic) {
      return normalized;
    }
    return normalized
        .split('')
        .map((ch) => _latinToArabicDigits[ch] ?? ch)
        .join();
  }

  BilingualText get _companyNameText => _resolveBilingual(
    fallback: const BilingualText(
      ar: 'تشارتر للمقاولات العامة والخدمات والتوريدات',
      en: 'Charter General Contracting, Services & Supplies',
    ),
    arOverride: overrides?.companyNameAr,
    enOverride: overrides?.companyNameEn,
  );

  String get companyName => _companyNameText.of(language);

  BilingualText get _companySubtitleText => _resolveBilingual(
    fallback: const BilingualText(
      ar: 'حلول هندسية ولوجستية وتوريدات متكاملة',
      en: 'Engineering, Logistics & Integrated Supply Solutions',
    ),
    arOverride: overrides?.companySubtitleAr,
    enOverride: overrides?.companySubtitleEn,
  );

  String get companySubtitle => _companySubtitleText.of(language);

  BilingualText get heroTitle => _resolveBilingual(
    fallback: const BilingualText(
      ar: 'نبني البنية التحتية ونُدير الإمداد من خلال شريك واحد',
      en: 'Building infrastructure and managing supply through one trusted partner',
    ),
    arOverride: overrides?.heroTitleAr,
    enOverride: overrides?.heroTitleEn,
  );

  BilingualText get heroDescription => _resolveBilingual(
    fallback: const BilingualText(
      ar: 'منذ عام ٢٠٢٠ تقدم تشارتر منظومة متكاملة تجمع المقاولات العامة والأعمال المعمارية والبنية التحتية والكهروميكانيكية مع التموين والتوريد والخدمات اللوجستية والتجارية والفنية.',
      en: 'Since 2020, Charter has combined general contracting, architectural, infrastructure, and electromechanical works with procurement, logistics, commercial, and technical services.',
    ),
    arOverride: overrides?.heroDescriptionAr,
    enOverride: overrides?.heroDescriptionEn,
  );

  BilingualText get heroTagline => const BilingualText(
    ar: 'مقران في مأرب وعدن، مع جاهزية ميدانية للعمل في كافة محافظات الجمهورية اليمنية.',
    en: 'Offices in Marib and Aden, with field readiness across all Yemeni governorates.',
  );

  BilingualText get ctaPrimary =>
      const BilingualText(ar: 'استعرض قطاعاتنا', en: 'Explore Our Divisions');

  BilingualText get ctaSecondary =>
      const BilingualText(ar: 'تواصل مع الفريق', en: 'Contact Team');

  List<HighlightPoint> get heroHighlights => const [
    HighlightPoint(
      title: BilingualText(ar: 'الجودة المطلقة', en: 'Absolute Quality'),
      description: BilingualText(
        ar: 'التزام صارم بمعايير الجودة في كل توريد وخدمة.',
        en: 'Strict quality standards across every supply and service.',
      ),
      icon: Icons.task_alt_rounded,
    ),
    HighlightPoint(
      title: BilingualText(ar: 'السرعة والفاعلية', en: 'Speed & Efficiency'),
      description: BilingualText(
        ar: 'تنفيذ سريع ودقيق مع انسيابية تشغيلية عالية.',
        en: 'Fast and precise execution with strong operational flow.',
      ),
      icon: Icons.schedule_rounded,
    ),
    HighlightPoint(
      title: BilingualText(
        ar: 'الموثوقية والنزاهة',
        en: 'Reliability & Integrity',
      ),
      description: BilingualText(
        ar: 'شراكات طويلة المدى مبنية على الثقة والوضوح.',
        en: 'Long-term partnerships built on trust and clarity.',
      ),
      icon: Icons.rocket_launch_rounded,
    ),
    HighlightPoint(
      title: BilingualText(ar: 'الابتكار المستمر', en: 'Continuous Innovation'),
      description: BilingualText(
        ar: 'حلول عملية ومبتكرة تلبي تطلعات السوق.',
        en: 'Practical, innovative solutions aligned with market needs.',
      ),
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  BilingualText get profileTitle =>
      const BilingualText(ar: 'الملف التعريفي', en: 'Company Profile');

  BilingualText get profileDescription => const BilingualText(
    ar: 'تعمل تشارتر عبر قطاعين متكاملين: المقاولات العامة التي تغطي الأعمال الإنشائية والمعمارية والبنية التحتية والكهروميكانيكية، والخدمات العامة والتوريدات التي تغطي الإمداد واللوجستيات والتجارة والطاقة والنقل والدعم الفني. يتيح هذا التكامل تنفيذ المشاريع من مرحلة البناء حتى التشغيل والإمداد.',
    en: 'Charter operates through two integrated divisions: General Contracting, covering structural, architectural, infrastructure, and electromechanical works; and General Services & Supplies, covering procurement, logistics, trading, energy, transport, and technical support. Together, they support projects from construction through operation and supply.',
  );

  BilingualText get establishedSince => const BilingualText(
    ar: 'تأسست الشركة عام ٢٠٢٠',
    en: 'Established in 2020',
  );

  BilingualText get visionTitle =>
      const BilingualText(ar: 'الرؤية', en: 'Vision');

  BilingualText get visionBody => const BilingualText(
    ar: 'أن نكون الوجهة الأولى في المقاولات العامة والخدمات والتوريدات من خلال حلول هندسية ولوجستية متكاملة، وبصمة ثابتة ترتبط بالجودة والتميز والابتكار في السوق المحلي والإقليمي.',
    en: 'To be the premier destination for general contracting, services, and supplies through integrated engineering and logistics solutions defined by quality, excellence, and innovation in local and regional markets.',
  );

  BilingualText get missionTitle =>
      const BilingualText(ar: 'الرسالة', en: 'Mission');

  BilingualText get missionBody => const BilingualText(
    ar: 'تسخير خبراتنا الهندسية واللوجستية والفنية لتقديم أعمال مقاولات وتوريد متفوقة، وتذليل العقبات أمام العملاء، وبناء الثقة في كل مرحلة، وتوفير حلول عملية مبتكرة تدعم نجاح شركائنا.',
    en: 'To leverage our engineering, logistics, and technical expertise to deliver superior contracting and supply services, remove client obstacles, build trust at every stage, and provide practical solutions that support partner success.',
  );

  BilingualText get valuesTitle =>
      const BilingualText(ar: 'القيم', en: 'Values');

  List<BilingualText> get values => const [
    BilingualText(ar: 'الجودة المطلقة', en: 'Absolute quality'),
    BilingualText(ar: 'السرعة والفاعلية', en: 'Speed and efficiency'),
    BilingualText(ar: 'الموثوقية والنزاهة', en: 'Reliability and integrity'),
    BilingualText(ar: 'الابتكار المستمر', en: 'Continuous innovation'),
  ];

  BilingualText get servicesTitle =>
      const BilingualText(ar: 'قطاعات أعمالنا', en: 'Our Business Divisions');

  BilingualText get servicesSubtitle => const BilingualText(
    ar: 'قطاعان متكاملان يغطّيان دورة المشروع من الإنشاء والتأهيل إلى التشغيل والإمداد والتوزيع.',
    en: 'Two integrated divisions covering the project lifecycle from construction and rehabilitation to operation, supply, and distribution.',
  );

  List<BusinessDivision> get businessDivisions => const [
    BusinessDivision(
      title: BilingualText(
        ar: 'تشارتر للمقاولات العامة',
        en: 'Charter for General Contracting',
      ),
      description: BilingualText(
        ar: 'تنفيذ متكامل للأعمال الإنشائية والمعمارية والبنية التحتية والكهروميكانيكية وفق معايير الجودة والسلامة الهندسية.',
        en: 'Integrated structural, architectural, infrastructure, and electromechanical delivery to rigorous engineering quality and safety standards.',
      ),
      icon: Icons.engineering_rounded,
      services: [
        ServiceItem(
          title: BilingualText(
            ar: 'الأعمال الإنشائية',
            en: 'Structural Construction',
          ),
          description: BilingualText(
            ar: 'مبانٍ سكنية وتجارية وحكومية وصناعية\nأعمال الحفر والردم والأساسات\nالإنشاءات الهيكلية وأعمال العظم\nالتشطيبات النهائية وضبط الجودة',
            en: 'Residential, commercial, government, and industrial buildings\nExcavation, backfilling, and foundations\nStructural frames and shell construction\nFinal finishes and quality control',
          ),
          icon: Icons.apartment_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'الأعمال المعمارية',
            en: 'Architectural Works',
          ),
          description: BilingualText(
            ar: 'اللياسة والدهانات والديكورات والأرضيات\nالأسقف المستعارة والنجارة والألمنيوم\nالأبواب والنوافذ والحديد المشغول والمطابخ\nعزل الأسطح والصوت وتنسيق المواقع\nالممرات والساحات والنوافير والشلالات',
            en: 'Plastering, painting, decoration, and flooring\nFalse ceilings, carpentry, and aluminum works\nDoors, windows, wrought iron, and kitchens\nRoof and sound insulation with site coordination\nWalkways, courtyards, fountains, and waterfalls',
          ),
          icon: Icons.architecture_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'البنية التحتية وإعادة التأهيل',
            en: 'Infrastructure & Rehabilitation',
          ),
          description: BilingualText(
            ar: 'إنشاء ورصف الطرق والجسور\nالسدود والحواجز ومشاريع حصاد المياه\nالآبار والخزانات وشبكات المياه والصرف\nالمدارس والجامعات والمستشفيات والمراكز الطبية\nمشاريع الزراعة والري والتنمية المستدامة',
            en: 'Road and bridge construction and paving\nDams, water barriers, and harvesting projects\nWells, tanks, water supply, and sewage networks\nSchools, universities, hospitals, and medical centers\nAgriculture, irrigation, and sustainable development projects',
          ),
          icon: Icons.add_road_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'الأعمال الكهروميكانيكية',
            en: 'Electromechanical Works',
          ),
          description: BilingualText(
            ar: 'شبكات السباكة وأنظمة مكافحة الحريق\nالتكييف والتهوية والتركيبات الكهربائية\nلوحات التوزيع وتمديد الشبكات وأنظمة الإنارة\nحلول الطاقة البديلة والصيانة الفنية',
            en: 'Plumbing networks and fire-fighting systems\nHVAC, ventilation, and electrical installations\nDistribution panels, network cabling, and lighting\nAlternative energy solutions and technical maintenance',
          ),
          icon: Icons.electrical_services_rounded,
        ),
      ],
    ),
    BusinessDivision(
      title: BilingualText(
        ar: 'تشارتر للخدمات العامة والتوريدات',
        en: 'Charter for General Services & Supplies',
      ),
      description: BilingualText(
        ar: 'شبكة توريد وتشغيل متخصصة تغطي التموين واللوجستيات والتجارة والطاقة والنقل والصيانة من المصدر حتى التسليم.',
        en: 'A specialized supply and operations network covering procurement, logistics, trading, energy, transport, and maintenance from source to final delivery.',
      ),
      icon: Icons.inventory_2_rounded,
      services: [
        ServiceItem(
          title: BilingualText(
            ar: 'التموين والتوريد',
            en: 'Supply & Procurement',
          ),
          description: BilingualText(
            ar: 'مواد غذائية وغير غذائية وإيوائية\nنظافة وكرامة وتجهيزات مؤقتة\nمعدات طبية وتعليمية ورياضية\nمدخلات زراعية وثروة حيوانية ومياه وطاقة\nقطع غيار ومستلزمات أمن وسلامة',
            en: 'Food, non-food, and shelter items\nHygiene, dignity, and temporary facilities\nMedical, educational, and sports supplies\nAgriculture, livestock, water, and energy supplies\nSpare parts and safety equipment',
          ),
          icon: Icons.warehouse_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'الخدمات اللوجستية',
            en: 'Logistical Services',
          ),
          description: BilingualText(
            ar: 'تخزين وتوزيع احترافي ومتكامل\nمستودعات مخصصة وإدارة مخزون\nتوريد الوقود والنقل والتخزين\nالتخليص الجمركي والاستيراد\nنقل لوجستي وتغطية ميدانية داخل اليمن',
            en: 'Professional storage and full-service distribution\nDedicated warehousing and inventory management\nFuel supply, transport, and storage\nCustoms clearance and import support\nLogistics transportation and field coverage across Yemen',
          ),
          icon: Icons.local_shipping_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'التسويق والتوزيع الاستراتيجي',
            en: 'Strategic Marketing & Distribution',
          ),
          description: BilingualText(
            ar: 'تحليل احتياجات السوق وبناء شبكات التوزيع\nتمويل تجاري وحلول توزيع ميداني ومبرد\nجداول تسليم دقيقة للمشاريع\nإدارة المخزون وسلاسل الإمداد\nمتابعة ما بعد التوزيع والدعم',
            en: 'Market analysis and distribution network development\nCommercial financing and refrigerated field distribution\nStrict project delivery schedules\nInventory and supply-chain management\nPost-distribution monitoring and support',
          ),
          icon: Icons.campaign_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'المشتقات النفطية',
            en: 'Petroleum Derivatives',
          ),
          description: BilingualText(
            ar: 'توريد ونقل النفط ومشتقاته\nمواد الحفر والتنقيب\nمعدات النفط وأنظمة التحكم والمراقبة\nزيوت وإطارات وملحقات تشغيلية',
            en: 'Supply and transportation of petroleum products\nDrilling and exploration materials\nOil equipment and control/monitoring systems\nOils, tires, and operational accessories',
          ),
          icon: Icons.oil_barrel_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'نقل وتأجير السيارات والمعدات',
            en: 'Vehicle & Heavy Equipment Transport and Rental',
          ),
          description: BilingualText(
            ar: 'سيارات دفع رباعي ومركبات خدمة\nحفارات ورافعات وشيولات\nمداحل وقلابات ومعدات طرق\nنقل وإدارة المركبات والمعدات الثقيلة',
            en: 'Four-wheel-drive and service vehicles\nExcavators, cranes, and loaders\nRollers, dump trucks, and road equipment\nTransport and management of vehicles and heavy equipment',
          ),
          icon: Icons.car_rental_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'التجارة العامة والتوكيلات',
            en: 'General Trading & Commercial Agencies',
          ),
          description: BilingualText(
            ar: 'الاستيراد وإدارة التوريدات الدولية\nتمثيل الوكالات والعلامات التجارية العالمية\nدعم قانوني وتسويقي وتشغيلي للمنتجات\nنقل دولي ومحلي وإدارة الشحنات',
            en: 'International import and supply management\nRepresentation of global agencies and brands\nLegal, marketing, and operational product support\nInternational/local transport and shipment management',
          ),
          icon: Icons.handshake_rounded,
        ),
        ServiceItem(
          title: BilingualText(
            ar: 'الصيانة والدعم الفني',
            en: 'Maintenance & Technical Support',
          ),
          description: BilingualText(
            ar: 'أعمال ميكانيكية وكهربائية وسباكة\nأنظمة إنارة ولوحات توزيع وتمديد شبكات\nترميم وصيانة المباني والمواقع\nتوريد وتجهيز معدات الأمن والسلامة',
            en: 'Mechanical, electrical, and plumbing works\nLighting, distribution panels, and network installations\nBuilding and site restoration and maintenance\nSupply and preparation of safety and security equipment',
          ),
          icon: Icons.build_circle_rounded,
        ),
      ],
    ),
  ];

  BilingualText get projectsTitle => const BilingualText(
    ar: 'القدرات والأهداف الاستراتيجية',
    en: 'Capabilities & Strategic Goals',
  );

  BilingualText get projectsSubtitle => const BilingualText(
    ar: 'نجمع التنفيذ الهندسي والإمداد التشغيلي ضمن منظومة نمو ترتكز على الاستدامة والتقنية والشراكات طويلة المدى.',
    en: 'We combine engineering delivery and operational supply within a growth model built on sustainability, technology, and long-term partnerships.',
  );

  BilingualText get capabilitiesTitle => const BilingualText(
    ar: 'أهدافنا الاستراتيجية',
    en: 'Our Strategic Goals',
  );

  BilingualText get capabilitiesBody => const BilingualText(
    ar: 'توسيع قاعدة العملاء وخدمة قطاعات حيوية جديدة.\nبناء منظومة مقاولات وتوريد متكاملة بأعلى كفاءة تشغيلية.\nتبني أحدث تقنيات إدارة المشاريع والمخزون وسلاسل الإمداد.\nبناء تحالفات استراتيجية مع العملاء والموردين والجهات المانحة.\nتقديم استشارات فنية ودعم لوجستي يتجاوز التوقعات.\nالالتزام الصارم بمعايير الجودة والسلامة والمسؤولية.',
    en: 'Expand our client base and serve new vital sectors.\nBuild an integrated contracting and supply system with strong operational efficiency.\nAdopt advanced project, inventory, and supply-chain technologies.\nBuild strategic alliances with clients, suppliers, and sponsors.\nProvide technical consultancy and logistics support beyond expectations.\nMaintain strict quality, safety, and responsibility standards.',
  );

  BilingualText get sectorsTitle =>
      const BilingualText(ar: 'القطاعات التي نخدمها', en: 'Sectors We Serve');

  List<BilingualText> get sectorsPoints => const [
    BilingualText(
      ar: 'الجهات الحكومية ومشاريع الطرق والبنية التحتية والمياه',
      en: 'Government, roads, infrastructure, and water projects',
    ),
    BilingualText(
      ar: 'التطوير العقاري والمباني التجارية والصناعية والسكنية',
      en: 'Real estate and commercial, industrial, and residential buildings',
    ),
    BilingualText(
      ar: 'المنظمات والبرامج الإنسانية والإغاثية',
      en: 'Humanitarian organizations and relief programs',
    ),
    BilingualText(
      ar: 'القطاع الصحي والتعليمي',
      en: 'Healthcare and education sectors',
    ),
    BilingualText(
      ar: 'الزراعة والري والثروة الحيوانية والأمن الغذائي',
      en: 'Agriculture, irrigation, livestock, and food security',
    ),
    BilingualText(
      ar: 'المياه والإصحاح البيئي والطاقة المتجددة',
      en: 'Water, environmental sanitation, and renewable energy',
    ),
    BilingualText(
      ar: 'النفط والنقل والتجارة وسلاسل الإمداد',
      en: 'Petroleum, transport, trading, and supply chains',
    ),
  ];

  BilingualText get credentialsTitle => const BilingualText(
    ar: 'محفظة الأعمال المتخصصة',
    en: 'Specialized Delivery Portfolio',
  );

  BilingualText get credentialsSubtitle => const BilingualText(
    ar: 'نطاق تفصيلي للقدرات المدرجة في ملفي المقاولات العامة والخدمات والتوريدات المحدثين.',
    en: 'A detailed view of the capabilities documented across the updated contracting and services profiles.',
  );

  List<PortfolioGroup> get portfolioGroups => const [
    PortfolioGroup(
      title: BilingualText(
        ar: 'المقاولات والإنشاء',
        en: 'Contracting & Construction',
      ),
      icon: Icons.construction_rounded,
      items: [
        BilingualText(
          ar: 'مبانٍ وإنشاءات هيكلية وتشطيبات',
          en: 'Buildings, structural works, and finishes',
        ),
        BilingualText(
          ar: 'أعمال معمارية وعزل وتنسيق مواقع',
          en: 'Architectural, insulation, and site works',
        ),
        BilingualText(
          ar: 'طرق وجسور ورصف وإعادة تأهيل',
          en: 'Roads, bridges, paving, and rehabilitation',
        ),
        BilingualText(
          ar: 'سدود وحواجز وحصاد مياه',
          en: 'Dams, barriers, and water harvesting',
        ),
        BilingualText(
          ar: 'مدارس ومستشفيات ومرافق عامة',
          en: 'Schools, hospitals, and public facilities',
        ),
        BilingualText(
          ar: 'كهروميكانيك وسباكة وحريق وتكييف',
          en: 'MEP, plumbing, fire systems, and HVAC',
        ),
      ],
    ),
    PortfolioGroup(
      title: BilingualText(
        ar: 'الإغاثة والتجهيز المؤسسي',
        en: 'Relief & Institutional Supply',
      ),
      icon: Icons.volunteer_activism_rounded,
      items: [
        BilingualText(
          ar: 'مواد غير غذائية وإيواء ومراتب وبطانيات',
          en: 'Non-food, shelter, mattress, and blanket supplies',
        ),
        BilingualText(
          ar: 'مواد نظافة وحقائب كرامة ومعالجة كلور',
          en: 'Hygiene, dignity, and chlorination supplies',
        ),
        BilingualText(
          ar: 'كرفانات وبيوت جاهزة وحاويات ودورات مياه',
          en: 'Caravans, prefabricated houses, containers, and toilets',
        ),
        BilingualText(
          ar: 'معدات طبية وتأهيل ذوي الاحتياجات',
          en: 'Medical and special-needs rehabilitation equipment',
        ),
        BilingualText(
          ar: 'قرطاسية وحقائب وأثاث وخيام تعليمية',
          en: 'Stationery, school bags, furniture, and educational tents',
        ),
        BilingualText(
          ar: 'معدات ومستلزمات رياضية',
          en: 'Sports supplies and equipment',
        ),
      ],
    ),
    PortfolioGroup(
      title: BilingualText(
        ar: 'الغذاء والزراعة والمياه',
        en: 'Food, Agriculture & Water',
      ),
      icon: Icons.agriculture_rounded,
      items: [
        BilingualText(
          ar: 'سلال غذائية طارئة ورمضانية ومتنوعة',
          en: 'Emergency, Ramadan, and assorted food baskets',
        ),
        BilingualText(
          ar: 'مواشٍ ولحوم طازجة ومجمدة وحلال',
          en: 'Livestock and fresh, frozen, and halal meat',
        ),
        BilingualText(
          ar: 'بيوت محمية وشبكات ري بالتنقيط والمحاور',
          en: 'Greenhouses, drip irrigation, and pivot networks',
        ),
        BilingualText(
          ar: 'شتلات ومدخلات وأدوات وأعلاف زراعية',
          en: 'Seedlings, agricultural inputs, tools, and feed',
        ),
        BilingualText(
          ar: 'معدات ومستلزمات بيطرية',
          en: 'Veterinary equipment and supplies',
        ),
        BilingualText(
          ar: 'نقل مياه وخزانات وتحلية ومعدات مشاريع',
          en: 'Water transport, tanks, desalination, and project equipment',
        ),
      ],
    ),
    PortfolioGroup(
      title: BilingualText(
        ar: 'الطاقة والنقل والصناعة',
        en: 'Energy, Transport & Industry',
      ),
      icon: Icons.energy_savings_leaf_rounded,
      items: [
        BilingualText(
          ar: 'أنظمة ضخ وطاقة وإنارة شمسية',
          en: 'Solar pumping, energy, and lighting systems',
        ),
        BilingualText(
          ar: 'قطع غيار كهربائية وإلكترونية ومعدات ثقيلة',
          en: 'Electrical, electronic, and heavy-equipment spare parts',
        ),
        BilingualText(
          ar: 'زيوت وإطارات وملحقات سيارات',
          en: 'Oils, tires, and vehicle accessories',
        ),
        BilingualText(
          ar: 'مشتقات نفطية ومواد حفر وتنقيب',
          en: 'Petroleum derivatives and drilling/exploration materials',
        ),
        BilingualText(
          ar: 'سيارات ومعدات ثقيلة للنقل والتأجير',
          en: 'Vehicles and heavy equipment for transport and rental',
        ),
        BilingualText(
          ar: 'معدات الأمن والسلامة والحماية',
          en: 'Safety, security, and protective equipment',
        ),
      ],
    ),
  ];

  BilingualText get locationsTitle =>
      const BilingualText(ar: 'مواقعنا وتغطيتنا', en: 'Locations & Coverage');

  BilingualText get locationsSubtitle => const BilingualText(
    ar: 'حضور تشغيلي في مأرب وعدن مع جاهزية ميدانية لتنفيذ المشاريع والتوريدات في جميع المحافظات.',
    en: 'Operational presence in Marib and Aden with field readiness for projects and supplies across all governorates.',
  );

  BilingualText get maribLabel => const BilingualText(
    ar: 'المقر الرئيسي - مأرب',
    en: 'Head Office - Marib',
  );

  BilingualText get adenLabel =>
      const BilingualText(ar: 'فرع عدن', en: 'Aden Branch');

  BilingualText get coverageLabel =>
      const BilingualText(ar: 'نطاق التغطية', en: 'Coverage Scope');

  BilingualText get maribAddress => _resolveBilingual(
    fallback: const BilingualText(
      ar: 'مأرب - المجمع - أمام سنجر كافيه',
      en: 'Marib - Al-Mujamma - in front of Sanjar Cafe',
    ),
    arOverride: overrides?.maribAddressAr,
    enOverride: overrides?.maribAddressEn,
  );

  BilingualText get adenAddress => _resolveBilingual(
    fallback: const BilingualText(
      ar: 'عدن - البريقة - مدينة إنماء الجديدة',
      en: 'Aden - Al-Buraiqa - New Inma City',
    ),
    arOverride: overrides?.adenAddressAr,
    enOverride: overrides?.adenAddressEn,
  );

  BilingualText get coverageAddress => _resolveBilingual(
    fallback: const BilingualText(
      ar: 'تغطية ميدانية لجميع محافظات الجمهورية اليمنية.',
      en: 'Field coverage across all Yemeni governorates.',
    ),
    arOverride: overrides?.coverageAr,
    enOverride: overrides?.coverageEn,
  );

  List<LocationItem> get locations => [
    LocationItem(
      title: maribLabel,
      address: maribAddress,
      icon: Icons.location_city_rounded,
    ),
    LocationItem(
      title: adenLabel,
      address: adenAddress,
      icon: Icons.apartment_rounded,
    ),
    LocationItem(
      title: coverageLabel,
      address: coverageAddress,
      icon: Icons.public_rounded,
    ),
  ];

  BilingualText get contactTitle =>
      const BilingualText(ar: 'تواصل معنا', en: 'Contact Us');

  BilingualText get contactSubtitle => const BilingualText(
    ar: 'لطلب عروض المقاولات والتوريد والخدمات اللوجستية والفنية والتجارية.',
    en: 'For contracting, supply, logistics, technical, and commercial proposals.',
  );

  String get contactPhoneRaw =>
      _normalizePhoneRaw(overrides?.officePhoneRaw, fallback: '967774863677');

  String get contactPhoneDisplay => _formatPhoneForDisplay(contactPhoneRaw);

  String get whatsappRaw =>
      _normalizePhoneRaw(overrides?.whatsappRaw, fallback: '967774863677');

  String get whatsappDisplay => _formatPhoneForDisplay(whatsappRaw);

  String get contactEmail =>
      _resolveText('info@charter-ye.com', overrides?.email);

  String get operationsEmail =>
      _resolveText('charter.t.s.y@gmail.com', overrides?.secondaryEmail);

  String get websiteUrl =>
      _resolveText('https://charter-ye.com', overrides?.websiteUrl);

  List<ContactItem> get contactItems => [
    ContactItem(
      label: const BilingualText(ar: 'هاتف المكتب', en: 'Office Phone'),
      value: contactPhoneDisplay,
      icon: Icons.phone_rounded,
      actionUrl: 'tel:+$contactPhoneRaw',
    ),
    ContactItem(
      label: const BilingualText(ar: 'واتساب', en: 'WhatsApp'),
      value: whatsappDisplay,
      icon: Icons.chat_rounded,
      actionUrl: 'https://wa.me/$whatsappRaw',
    ),
    ContactItem(
      label: const BilingualText(ar: 'البريد الإلكتروني', en: 'Email'),
      value: contactEmail,
      icon: Icons.email_rounded,
      actionUrl: 'mailto:$contactEmail',
    ),
    ContactItem(
      label: const BilingualText(ar: 'بريد العمليات', en: 'Operations Email'),
      value: operationsEmail,
      icon: Icons.alternate_email_rounded,
      actionUrl: 'mailto:$operationsEmail',
    ),
    ContactItem(
      label: const BilingualText(ar: 'الموقع الإلكتروني', en: 'Website'),
      value: websiteUrl.replaceFirst(RegExp(r'^https?://'), ''),
      icon: Icons.language_rounded,
      actionUrl: websiteUrl,
    ),
  ];

  BilingualText get formTitle =>
      const BilingualText(ar: 'طلب خدمة', en: 'Service Request');

  BilingualText get formHintName =>
      const BilingualText(ar: 'الاسم الكامل', en: 'Full name');

  BilingualText get formHintCompany => const BilingualText(
    ar: 'اسم الجهة / الشركة',
    en: 'Organization / Company',
  );

  BilingualText get formHintService =>
      const BilingualText(ar: 'نوع الخدمة المطلوبة', en: 'Requested service');

  BilingualText get formHintMessage =>
      const BilingualText(ar: 'تفاصيل الطلب', en: 'Request details');

  BilingualText get formSubmit =>
      const BilingualText(ar: 'إرسال الطلب', en: 'Submit Request');

  BilingualText get formSendByEmail =>
      const BilingualText(ar: 'فتح البريد', en: 'Open Email');

  BilingualText get formValidationRequired => const BilingualText(
    ar: 'هذا الحقل مطلوب.',
    en: 'This field is required.',
  );

  BilingualText get formValidationMinLength => const BilingualText(
    ar: 'البيانات قصيرة جدًا.',
    en: 'Input is too short.',
  );

  BilingualText get formValidationTooLong =>
      const BilingualText(ar: 'النص طويل جدًا.', en: 'Input is too long.');

  BilingualText get formRateLimitMessage => const BilingualText(
    ar: 'يرجى الانتظار قليلًا قبل إرسال طلب جديد.',
    en: 'Please wait a moment before submitting another request.',
  );

  BilingualText get formSubmitError => const BilingualText(
    ar: 'تعذر إرسال الطلب الآن. حاول مرة أخرى.',
    en: 'Unable to submit now. Please try again.',
  );

  BilingualText get formSuccess => const BilingualText(
    ar: 'تم استلام طلبك بنجاح وسيتواصل معك فريقنا قريبًا.',
    en: 'Your request was received successfully. Our team will contact you shortly.',
  );

  BilingualText get formOpenContactError => const BilingualText(
    ar: 'تعذر فتح وسيلة التواصل. يمكنك المحاولة مجددًا أو التواصل مباشرة.',
    en: 'Unable to open contact method. Please try again or contact us directly.',
  );

  BilingualText get footerTagline => const BilingualText(
    ar: 'حلول متكاملة للمقاولات والبنية التحتية والخدمات والتوريدات.',
    en: 'Integrated contracting, infrastructure, services, and supply solutions.',
  );

  List<NavItem> get navItems => [
    NavItem(
      section: LandingSection.home,
      label: isArabic ? 'الرئيسية' : 'Home',
    ),
    NavItem(
      section: LandingSection.profile,
      label: isArabic ? 'الملف' : 'Profile',
    ),
    NavItem(
      section: LandingSection.services,
      label: isArabic ? 'الخدمات' : 'Services',
    ),
    NavItem(
      section: LandingSection.projects,
      label: isArabic ? 'القدرات والأهداف' : 'Capabilities',
    ),
    NavItem(
      section: LandingSection.credentials,
      label: isArabic ? 'محفظة الأعمال' : 'Portfolio',
    ),
    NavItem(
      section: LandingSection.locations,
      label: isArabic ? 'المواقع والتغطية' : 'Locations',
    ),
    NavItem(
      section: LandingSection.contact,
      label: isArabic ? 'تواصل' : 'Contact',
    ),
  ];
}
