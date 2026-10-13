class Appointments {
  final String? id;
  final String patientId;
  final PatientInfo patientInfo;
  final String bookingFor;
  final Referral? referral;
  final String branchId;
  final String department;
  final String doctorId;
  final Scheduling scheduling;
  final String? personalRequest;
  final String status;
  final String? hospitalNotes;
  final DateTime? createdAt;

  const Appointments({
    required this.patientId,
    required this.patientInfo,
    required this.bookingFor,
    required this.branchId,
    required this.department,
    required this.doctorId,
    required this.scheduling,
    required this.status,
    this.referral,
    this.personalRequest,
    this.hospitalNotes,
    this.id,
    this.createdAt,
  });

  factory Appointments.fromJson(Map<String, dynamic> json) => Appointments(
    id: json['id'] as String?,
    patientId: json['patientId'] as String,
    patientInfo: PatientInfo.fromJson(
      json['patientInfo'] as Map<String, dynamic>,
    ),
    bookingFor: json['bookingFor'] as String,
    referral: json['referral'] != null
        ? Referral.fromJson(json['referral'] as Map<String, dynamic>)
        : null,
    branchId: json['branchId'] as String,
    department: json['department'] as String,
    doctorId: json['doctorId'] as String,
    scheduling: Scheduling.fromJson(
      json['scheduling'] as Map<String, dynamic>,
    ),
    personalRequest: json['personalRequest'] as String?,
    status: json['status'] as String,
    hospitalNotes: json['hospitalNotes'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
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
    isEarliestAvailable: json['isEarliestAvailable'] as bool,
    requestedDate: DateTime.parse(json['requestedDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'isEarliestAvailable': isEarliestAvailable,
    'requestedDate': requestedDate.toIso8601String(),
  };
}
