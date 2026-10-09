import 'package:mongo_dart/mongo_dart.dart';

class Clinics {
  final String? id;
  final String name;
  final String code;
  final String description;
  final String logoUrl;
  final List<String> supportedBranchIds;
  final bool isActive;

  const Clinics({
    this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.logoUrl,
    required this.supportedBranchIds,
    required this.isActive,
  });

  factory Clinics.fromJson(Map<String, dynamic> json) => Clinics(
    id: json['id'] != null ? (json['id'] as ObjectId).oid : null,
    name: json['name'] as String,
    code: json['code'] as String,
    description: json['description'] as String,
    logoUrl: json['logoUrl'] as String,
    supportedBranchIds: (json['supportedBranchIds'] as List)
        .map((e) => e as String)
        .toList(),
    isActive: json['isActive'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'logoUrl': logoUrl,
    'supportedBranchIds': supportedBranchIds,
    'isActive': isActive,
  };
}
