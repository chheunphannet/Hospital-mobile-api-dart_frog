import 'package:mongo_dart/mongo_dart.dart';

class RefreshTokens {
  final String? id;
  final String tokenHash;
  final String userId;
  final String email;
  final String role;
  final String? branchId;
  final DeviceInfo deviceInfo;
  final DateTime expiresAt;
  final DateTime createdAt;
  final bool isRevoked;

  const RefreshTokens({
    this.id,
    required this.tokenHash,
    required this.userId,
    required this.email,
    required this.role,
    this.branchId,
    required this.deviceInfo,
    required this.expiresAt,
    required this.createdAt,
    this.isRevoked = false,
  });

  factory RefreshTokens.fromMap(Map<String, dynamic> json) => RefreshTokens(
    id: json['_id'] != null
        ? (json['_id'] is ObjectId
            ? (json['_id'] as ObjectId).oid
            : json['_id'].toString())
        : null,
    tokenHash: json['tokenHash'] as String,
    userId: json['userId'] is ObjectId
        ? (json['userId'] as ObjectId).oid
        : json['userId'].toString(),
    email: json['email'] as String,
    role: json['role'] as String,
    branchId: json['branchId'] != null
        ? (json['branchId'] is ObjectId
            ? (json['branchId'] as ObjectId).oid
            : json['branchId'].toString())
        : null,
    deviceInfo: DeviceInfo.fromJson(json['deviceInfo'] as Map<String, dynamic>),
    expiresAt: json['expiresAt'] is DateTime
        ? json['expiresAt'] as DateTime
        : DateTime.parse(json['expiresAt'].toString()),
    createdAt: json['createdAt'] is DateTime
        ? json['createdAt'] as DateTime
        : DateTime.parse(json['createdAt'].toString()),
    isRevoked: json['isRevoked'] as bool? ?? false,
  );

  factory RefreshTokens.fromJson(Map<String, dynamic> json) =>
      RefreshTokens.fromMap(json);

  Map<String, dynamic> toDocument() => {
    'tokenHash': tokenHash,
    'userId': ObjectId.fromHexString(userId),
    'email': email,
    'role': role,
    if (branchId != null) 'branchId': ObjectId.fromHexString(branchId!),
    'deviceInfo': deviceInfo.toJson(),
    'expiresAt': expiresAt,
    'createdAt': createdAt,
    'isRevoked': isRevoked,
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'email': email,
    'role': role,
    'branchId': branchId,
    'deviceInfo': deviceInfo.toJson(),
    'expiresAt': expiresAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isRevoked': isRevoked,
  };
}

class DeviceInfo {
  final String deviceId;
  final String platform;
  final String ipAddress;

  const DeviceInfo({
    required this.deviceId,
    required this.platform,
    required this.ipAddress,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    deviceId: json['deviceId'] as String? ?? 'unknown',
    platform: json['platform'] as String? ?? 'unknown',
    ipAddress: json['ipAddress'] as String? ?? 'unknown',
  );

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'platform': platform,
    'ipAddress': ipAddress,
  };
}
