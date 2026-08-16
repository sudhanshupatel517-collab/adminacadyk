class EventModel {
  final String id;
  final String title;
  final String description;
  final String organizer;
  final String organizerLogoUrl;
  final String bannerUrl;
  final String eventType; // hackathon, workshop, etc.
  final String mode; // online, offline, hybrid
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? registrationDeadline;
  final int? maxParticipants;
  final String prizePool;
  final String eligibility;
  final List<String> tags;
  final String websiteUrl;
  final bool isFeatured;
  final int registrationsCount;
  final String? createdBy;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.organizer,
    required this.organizerLogoUrl,
    required this.bannerUrl,
    required this.eventType,
    required this.mode,
    required this.location,
    this.startDate,
    this.endDate,
    this.registrationDeadline,
    this.maxParticipants,
    required this.prizePool,
    required this.eligibility,
    required this.tags,
    required this.websiteUrl,
    required this.isFeatured,
    required this.registrationsCount,
    this.createdBy,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      organizer: json['organizer'] ?? '',
      organizerLogoUrl: json['organizer_logo_url'] ?? '',
      bannerUrl: json['banner_url'] ?? '',
      eventType: json['event_type'] ?? 'hackathon',
      mode: json['mode'] ?? 'online',
      location: json['location'] ?? '',
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.parse(json['registration_deadline'])
          : null,
      maxParticipants: json['max_participants'],
      prizePool: json['prize_pool'] ?? '',
      eligibility: json['eligibility'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      websiteUrl: json['website_url'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      registrationsCount: json['registrations_count'] ?? 0,
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'organizer': organizer,
      'organizer_logo_url': organizerLogoUrl,
      'banner_url': bannerUrl,
      'event_type': eventType,
      'mode': mode,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'max_participants': maxParticipants,
      'prize_pool': prizePool,
      'eligibility': eligibility,
      'tags': tags,
      'website_url': websiteUrl,
      'is_featured': isFeatured,
      'registrations_count': registrationsCount,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
