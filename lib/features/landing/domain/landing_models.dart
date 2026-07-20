import 'package:flutter/material.dart';

enum Language { ar, en }

enum LandingSection {
  home,
  profile,
  services,
  projects,
  credentials,
  locations,
  contact,
}

class BilingualText {
  const BilingualText({required this.ar, required this.en});

  final String ar;
  final String en;

  String of(Language language) => language == Language.ar ? ar : en;
}

class NavItem {
  const NavItem({required this.section, required this.label});

  final LandingSection section;
  final String label;
}

class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final BilingualText title;
  final BilingualText description;
  final IconData icon;
}

class BusinessDivision {
  const BusinessDivision({
    required this.title,
    required this.description,
    required this.icon,
    required this.services,
  });

  final BilingualText title;
  final BilingualText description;
  final IconData icon;
  final List<ServiceItem> services;
}

class PortfolioGroup {
  const PortfolioGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final BilingualText title;
  final IconData icon;
  final List<BilingualText> items;
}

class DeliveryShowcase {
  const DeliveryShowcase({
    required this.title,
    required this.summary,
    required this.icon,
    required this.tags,
  });

  final BilingualText title;
  final BilingualText summary;
  final IconData icon;
  final List<BilingualText> tags;
}

class LocationItem {
  const LocationItem({
    required this.title,
    required this.address,
    required this.icon,
    this.mapUrl,
  });

  final BilingualText title;
  final BilingualText address;
  final IconData icon;
  final String? mapUrl;
}

class HighlightPoint {
  const HighlightPoint({
    required this.title,
    required this.description,
    required this.icon,
  });

  final BilingualText title;
  final BilingualText description;
  final IconData icon;
}

class ContactItem {
  const ContactItem({
    required this.label,
    required this.value,
    required this.icon,
    this.actionUrl,
  });

  final BilingualText label;
  final String value;
  final IconData icon;
  final String? actionUrl;
}
