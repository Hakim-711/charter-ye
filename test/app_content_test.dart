import 'package:charter_company/features/admin/domain/site_admin_settings.dart';
import 'package:charter_company/features/landing/data/app_content.dart';
import 'package:charter_company/features/landing/domain/landing_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('covers both updated business profiles', () {
    final content = AppContent.of(Language.en);

    expect(content.businessDivisions, hasLength(2));
    expect(content.businessDivisions.first.services, hasLength(4));
    expect(content.businessDivisions.last.services, hasLength(7));
    expect(
      content.businessDivisions.first.title.en,
      'Charter for General Contracting',
    );
    expect(
      content.businessDivisions.last.title.en,
      'Charter for General Services & Supplies',
    );
    expect(content.portfolioGroups, hasLength(4));
    expect(content.locations, hasLength(3));
  });

  test('uses updated published contact defaults', () {
    final content = AppContent.of(Language.en);

    expect(content.contactPhoneRaw, '967774863677');
    expect(content.whatsappRaw, '967774863677');
    expect(content.contactEmail, 'info@charter-ye.com');
    expect(content.operationsEmail, 'charter.t.s.y@gmail.com');
    expect(content.websiteUrl, 'https://charter-ye.com');
  });

  test('serializes new location and contact overrides', () {
    const settings = SiteAdminSettings(
      secondaryEmail: 'operations@example.com',
      adenAddressAr: 'عدن',
      adenAddressEn: 'Aden',
    );

    final decoded = SiteAdminSettings.fromJson(settings.toJson());

    expect(decoded.secondaryEmail, 'operations@example.com');
    expect(decoded.adenAddressAr, 'عدن');
    expect(decoded.adenAddressEn, 'Aden');
  });
}
