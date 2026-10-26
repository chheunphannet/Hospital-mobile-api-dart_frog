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
    this.isActive = true,
  });

  factory Clinics.fromJson(Map<String, dynamic> json) => Clinics(
    id: json['_id'] != null
        ? (json['_id'] is ObjectId
            ? (json['_id'] as ObjectId).oid
            : json['_id'].toString())
        : (json['id'] as String?),
    name: json['name'] as String,
    code: json['code'] as String,
    description: json['description'] as String? ?? '',
    logoUrl: json['logoUrl'] as String? ?? '',
    supportedBranchIds: (json['supportedBranchIds'] as List<dynamic>?)
            ?.map((e) => e is ObjectId ? e.oid : e.toString())
            .toList() ??
        const [],
    isActive: json['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toDocument() => {
    'name': name,
    'code': code,
    'description': description,
    'logoUrl': logoUrl,
    'supportedBranchIds': supportedBranchIds.map((id) {
      try {
        return ObjectId.fromHexString(id);
      } catch (_) {
        return id;
      }
    }).toList(),
    'isActive': isActive,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'description': description,
    'logoUrl': logoUrl,
    'supportedBranchIds': supportedBranchIds,
    'isActive': isActive,
  };
}
