import 'package:mongo_dart/mongo_dart.dart';

/// Doctor data model representing a healthcare practitioner.
class Doctors {
  /// Creates a [Doctors] model instance.
  const Doctors({
    required this.name,
    required this.clinicId,
    required this.branchesId,
    required this.photoUrl,
    required this.bio,
    required this.qualifications,
    required this.languagesSpoken,
    this.id,
    this.title,
    this.isAvailableForBooking = true,
  });

  /// Creates a [Doctors] model from a JSON map.
  factory Doctors.fromJson(Map<String, dynamic> json) => Doctors(
    id: json['_id'] != null
        ? (json['_id'] is ObjectId
            ? (json['_id'] as ObjectId).oid
            : json['_id'].toString())
        : (json['id'] as String?),
    name: json['name'] as String,
    title: json['title'] as String?,
    clinicId: json['clinicId'] is ObjectId
        ? (json['clinicId'] as ObjectId).oid
        : json['clinicId'].toString(),
    branchesId: ((json['branchesId'] ?? json['branchIds']) as List<dynamic>?)
            ?.map((e) => e is ObjectId ? e.oid : e.toString())
            .toList() ??
        const [],
    photoUrl: json['photoUrl'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    languagesSpoken: (json['languagesSpoken'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    qualifications: (json['qualifications'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    isAvailableForBooking: json['isAvailableForBooking'] as bool? ?? true,
  );

  /// MongoDB ObjectId string.
  final String? id;

  /// Full professional name of the doctor.
  final String name;

  /// Medical title or specialization summary.
  final String? title;

  /// Associated clinic ID.
  final String clinicId;

  /// Associated hospital branch IDs.
  final List<String> branchesId;

  /// Profile photo URL.
  final String photoUrl;

  /// Professional bio.
  final String bio;

  /// Languages spoken by the doctor.
  final List<String> languagesSpoken;

  /// Degrees and qualifications.
  final List<String> qualifications;

  /// Availability flag for patient booking.
  final bool isAvailableForBooking;

  /// Converts the doctor model to a MongoDB document.
  Map<String, dynamic> toDocument() => {
    'name': name,
    if (title != null) 'title': title,
    'clinicId': _toObjectId(clinicId) ?? clinicId,
    'branchIds': branchesId.map((id) => _toObjectId(id) ?? id).toList(),
    'photoUrl': photoUrl,
    'bio': bio,
    'languagesSpoken': languagesSpoken,
    'qualifications': qualifications,
    'isAvailableForBooking': isAvailableForBooking,
  };

  /// Converts the doctor model to a JSON response map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (title != null) 'title': title,
    'clinicId': clinicId,
    'branchesId': branchesId,
    'photoUrl': photoUrl,
    'bio': bio,
    'languagesSpoken': languagesSpoken,
    'qualifications': qualifications,
    'isAvailableForBooking': isAvailableForBooking,
  };
}

ObjectId? _toObjectId(String? id) {
  if (id == null) return null;
  try {
    return ObjectId.fromHexString(id);
  } catch (_) {
    return null;
  }
}
