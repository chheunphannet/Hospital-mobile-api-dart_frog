import 'package:mongo_dart/mongo_dart.dart';

class Doctors {
  final String? id;
  final String name;
  final String clinicId;
  final List<String> branchesId;
  final String photoUrl;
  final String bio;
  final List<String> languagesSpoken;
  final List<String> qualifications;
  final bool isAvailableForBooking;

  const Doctors({
    this.id,
    required this.name,
    required this.clinicId,
    required this.branchesId,
    required this.photoUrl,
    required this.bio,
    required this.qualifications,
    required this.languagesSpoken,
    required this.isAvailableForBooking,
  });

  factory Doctors.fromJson(Map<String, dynamic> json) => Doctors(
    id: json['_id'] != null ? (json['_id'] as ObjectId).oid : null,
    name: json['name'] as String,
    clinicId: json['clinicId'] as String,
    branchesId: (json['branchesId'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    photoUrl: json['photoUrl'] as String,
    bio: json['bio'] as String,
    languagesSpoken: (json['languagesSpoken'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    qualifications: (json['qualifications'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    isAvailableForBooking: json['isAvailableForBooking'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'clinicId': clinicId,
    'branchesId': branchesId,
    'photoUrl': photoUrl,
    'bio': bio,
    'languagesSpoken': languagesSpoken,
    'qualifications': qualifications,
    'isAvailableForBooking': isAvailableForBooking,
  };
}
