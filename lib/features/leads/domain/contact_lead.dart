enum LeadStatus { newLead, contacted, closed }

class ContactLeadDraft {
  const ContactLeadDraft({
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.service,
    required this.message,
  });

  final String name;
  final String company;
  final String phone;
  final String email;
  final String service;
  final String message;
}

class ContactLead {
  const ContactLead({
    required this.id,
    required this.createdAtIso,
    required this.name,
    required this.company,
    required this.phone,
    required this.email,
    required this.service,
    required this.message,
    required this.status,
  });

  final String id;
  final String createdAtIso;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String service;
  final String message;
  final LeadStatus status;

  DateTime get createdAt {
    return DateTime.tryParse(createdAtIso) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  ContactLead copyWith({
    String? id,
    String? createdAtIso,
    String? name,
    String? company,
    String? phone,
    String? email,
    String? service,
    String? message,
    LeadStatus? status,
  }) {
    return ContactLead(
      id: id ?? this.id,
      createdAtIso: createdAtIso ?? this.createdAtIso,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      service: service ?? this.service,
      message: message ?? this.message,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAtIso': createdAtIso,
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'service': service,
      'message': message,
      'status': status.name,
    };
  }

  factory ContactLead.fromJson(Map<String, dynamic> json) {
    final statusName = (json['status'] as String?) ?? LeadStatus.newLead.name;
    return ContactLead(
      id: (json['id'] as String?) ?? '',
      createdAtIso: (json['createdAtIso'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      company: (json['company'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      service: (json['service'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      status: LeadStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => LeadStatus.newLead,
      ),
    );
  }
}
