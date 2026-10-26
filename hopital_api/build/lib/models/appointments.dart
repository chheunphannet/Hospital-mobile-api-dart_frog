import 'package:mongo_dart/mongo_dart.dart';

class Appointments {
  final String? id;
  final String patientId;
  final String?
  packageId; // Optional: when booked for a medical checkup package
  final PatientInfo patientInfo;
  final String bookingFor;
  final Referral? referral;
  final String branchId;
  final String department;
  final String?
  doctorId; // Optional: package checkups may not require a specific doctor
  final Scheduling scheduling;
  final String? personalRequest;
  final String status;
  final String? hospitalNotes;
  final DateTime? createdAt;

  const Appointments({
    this.id,
    required this.patientId,
    this.packageId,
    required this.patientInfo,
    required this.bookingFor,
    required this.branchId,
    required this.department,
    this.doctorId,
    required this.scheduling,
    this.status = 'pending',
    this.referral,
    this.personalRequest,
    this.hospitalNotes,
    this.createdAt,
  });

  factory Appointments.fromJson(Map<String, dynamic> json) => Appointments(
    id: json['_id'] != null
        ? (json['_id'] is ObjectId
              ? (json['_id'] as ObjectId).oid
              : json['_id'].toString())
        : (json['id'] as String?),
    patientId: json['patientId'] is ObjectId
        ? (json['patientId'] as ObjectId).oid
        : json['patientId'].toString(),
    packageId: json['packageId'] != null
        ? (json['packageId'] is ObjectId
              ? (json['packageId'] as ObjectId).oid
              : json['packageId'].toString())
        : null,
    patientInfo: PatientInfo.fromJson(
      json['patientInfo'] as Map<String, dynamic>,
    ),
    bookingFor: json['bookingFor'] as String? ?? 'Myself',
    referral: json['referral'] != null
        ? Referral.fromJson(json['referral'] as Map<String, dynamic>)
        : null,
    branchId: json['branchId'] is ObjectId
        ? (json['branchId'] as ObjectId).oid
        : json['branchId'].toString(),
    department: json['department'] as String,
    doctorId: json['doctorId'] != null
        ? (json['doctorId'] is ObjectId
              ? (json['doctorId'] as ObjectId).oid
              : json['doctorId'].toString())
        : null,
    scheduling: Scheduling.fromJson(
      json['scheduling'] as Map<String, dynamic>,
    ),
    personalRequest: json['personalRequest'] as String?,
    status: json['status'] as String? ?? 'pending',
    hospitalNotes: json['hospitalNotes'] as String?,
    createdAt: json['createdAt'] is DateTime
        ? json['createdAt'] as DateTime
        : (json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null),
  );

  /// For saving to MongoDB (stores ObjectId and BSON DateTime)
  Map<String, dynamic> toDocument() => {
    'patientId': ObjectId.fromHexString(patientId),
    if (packageId != null) 'packageId': ObjectId.fromHexString(packageId!),
    'patientInfo': patientInfo.toJson(),
    'bookingFor': bookingFor,
    if (referral != null) 'referral': referral?.toJson(),
    'branchId': ObjectId.fromHexString(branchId),
    'department': department,
    if (doctorId != null) 'doctorId': ObjectId.fromHexString(doctorId!),
    'scheduling': scheduling.toDocument(),
    if (personalRequest != null) 'personalRequest': personalRequest,
    'status': status,
    if (hospitalNotes != null) 'hospitalNotes': hospitalNotes,
    'createdAt': createdAt ?? DateTime.now().toUtc(),
  };

  /// For HTTP JSON responses to Flutter
  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'packageId': packageId,
    'patientInfo': patientInfo.toJson(),
    'bookingFor': bookingFor,
    'referral': referral?.toJson(),
    'branchId': branchId,
    'department': department,
    'doctorId': doctorId,
    'scheduling': scheduling.toJson(),
    'personalRequest': personalRequest,
    'status': status,
    'hospitalNotes': hospitalNotes,
    'createdAt': createdAt?.toIso8601String(),
  };
}

class PatientInfo {
  final String name;
  final String email;
  final String phone;

  const PatientInfo({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) => PatientInfo(
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };
}

class Referral {
  final String type;
  final String sourceName;

  const Referral({
    required this.type,
    required this.sourceName,
  });

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
    type: json['type'] as String,
    sourceName: json['sourceName'] as String,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'sourceName': sourceName,
  };
}

class Scheduling {
  final bool isEarliestAvailable;
  final DateTime requestedDate;

  const Scheduling({
    required this.isEarliestAvailable,
    required this.requestedDate,
  });

  factory Scheduling.fromJson(Map<String, dynamic> json) => Scheduling(
    isEarliestAvailable: json['isEarliestAvailable'] as bool? ?? false,
    requestedDate: json['requestedDate'] is DateTime
        ? json['requestedDate'] as DateTime
        : DateTime.parse(json['requestedDate'].toString()),
  );

  Map<String, dynamic> toDocument() => {
    'isEarliestAvailable': isEarliestAvailable,
    'requestedDate': requestedDate, // Keep as DateTime for MongoDB
  };

  Map<String, dynamic> toJson() => {
    'isEarliestAvailable': isEarliestAvailable,
    'requestedDate': requestedDate.toIso8601String(),
  };
}
