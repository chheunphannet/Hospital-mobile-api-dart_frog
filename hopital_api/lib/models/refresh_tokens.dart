import 'package:mongo_dart/mongo_dart.dart';

class RefreshTokens {
  final String? id;
  final String tokenHash;
  final String userId;
  final String email;
  final String role;
  final String branchId;
  final DeviceInfo deviceInfo;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final bool isRevoked;

  const RefreshTokens({
    this.id,
    required this.tokenHash,
    required this.userId,
    required this.email,
    required this.role,
    required this.branchId,
    required this.deviceInfo,
    this.expiresAt,
    this.createdAt,
    required this.isRevoked,
  });

  factory RefreshTokens.fromJson(Map<String, dynamic> json) => RefreshTokens(
    id: (json['_id'] as ObjectId).oid,
    tokenHash: json['tokenHash'] as String,
    userId: json['userId'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    branchId: json['branchId'] as String,
    deviceInfo: DeviceInfo.fromJson(json['deviceInfo'] as Map<String, dynamic>),
    createdAt: json['createdAt'] as DateTime,
    expiresAt: json['expiresAt'] as DateTime,
    isRevoked: json['isRevoked'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tokenHash': tokenHash,
    'userId': userId,
    'email': email,
    'role': role,
    'branchId': branchId,
    'deviceId': deviceInfo.toJson(),
    'expiresAt': expiresAt?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
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
    deviceId: json['deviceId'] as String,
    platform: json['platform'] as String,
    ipAddress: json['ipAddress'] as String,
  );

  Map<String, dynamic> toJson() {
    return {'deviceId': deviceId, 'platform': platform, 'ipAddress': ipAddress};
  }
}
