import 'package:mongo_dart/mongo_dart.dart';

class Payments {
  final String? id;
  final String patientId;
  final String? appointmentId;
  final String? packageId;
  final String billNumber;
  final double amount;
  final String currency; // 'USD' or 'KHR'
  final String qrString;
  final String md5Hash;
  final String status; // 'pending', 'paid', 'expired', 'failed'
  final String? transactionHash;
  final String? fromAccountId;
  final DateTime? paidAt;
  final DateTime expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Payments({
    this.id,
    required this.patientId,
    this.appointmentId,
    this.packageId,
    required this.billNumber,
    required this.amount,
    this.currency = 'USD',
    required this.qrString,
    required this.md5Hash,
    this.status = 'pending',
    this.transactionHash,
    this.fromAccountId,
    this.paidAt,
    required this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Payments.fromJson(Map<String, dynamic> json) => Payments(
    id: json['_id'] != null
        ? (json['_id'] is ObjectId
              ? (json['_id'] as ObjectId).oid
              : json['_id'].toString())
        : (json['id'] as String?),
    patientId: json['patientId'] is ObjectId
        ? (json['patientId'] as ObjectId).oid
        : json['patientId'].toString(),
    appointmentId: json['appointmentId'] != null
        ? (json['appointmentId'] is ObjectId
              ? (json['appointmentId'] as ObjectId).oid
              : json['appointmentId'].toString())
        : null,
    packageId: json['packageId'] != null
        ? (json['packageId'] is ObjectId
              ? (json['packageId'] as ObjectId).oid
              : json['packageId'].toString())
        : null,
    billNumber: json['billNumber'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'USD',
    qrString: json['qrString'] as String,
    md5Hash: json['md5Hash'] as String,
    status: json['status'] as String? ?? 'pending',
    transactionHash: json['transactionHash'] as String?,
    fromAccountId: json['fromAccountId'] as String?,
    paidAt: json['paidAt'] is DateTime
        ? json['paidAt'] as DateTime
        : (json['paidAt'] != null
              ? DateTime.tryParse(json['paidAt'].toString())
              : null),
    expiresAt: json['expiresAt'] is DateTime
        ? json['expiresAt'] as DateTime
        : DateTime.parse(json['expiresAt'].toString()),
    createdAt: json['createdAt'] is DateTime
        ? json['createdAt'] as DateTime
        : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
    updatedAt: json['updatedAt'] is DateTime
        ? json['updatedAt'] as DateTime
        : (json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null),
  );

  Map<String, dynamic> toDocument() => {
    'patientId': ObjectId.fromHexString(patientId),
    if (appointmentId != null)
      'appointmentId': ObjectId.fromHexString(appointmentId!),
    if (packageId != null) 'packageId': ObjectId.fromHexString(packageId!),
    'billNumber': billNumber,
    'amount': amount,
    'currency': currency,
    'qrString': qrString,
    'md5Hash': md5Hash,
    'status': status,
    if (transactionHash != null) 'transactionHash': transactionHash,
    if (fromAccountId != null) 'fromAccountId': fromAccountId,
    if (paidAt != null) 'paidAt': paidAt,
    'expiresAt': expiresAt,
    'createdAt': createdAt ?? DateTime.now().toUtc(),
    'updatedAt': updatedAt ?? DateTime.now().toUtc(),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    if (appointmentId != null) 'appointmentId': appointmentId,
    if (packageId != null) 'packageId': packageId,
    'billNumber': billNumber,
    'amount': amount,
    'currency': currency,
    'qrString': qrString,
    'md5Hash': md5Hash,
    'status': status,
    if (transactionHash != null) 'transactionHash': transactionHash,
    if (fromAccountId != null) 'fromAccountId': fromAccountId,
    if (paidAt != null) 'paidAt': paidAt?.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    if (createdAt != null) 'createdAt': createdAt?.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt?.toIso8601String(),
  };
}
