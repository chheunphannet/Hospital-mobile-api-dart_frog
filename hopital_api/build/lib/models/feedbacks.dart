import 'package:mongo_dart/mongo_dart.dart';

class Feedbacks {
  final String? id;
  final String patientId;
  final FeedbackPersonalInfo personalInfo;
  final FeedbackContact contact;
  final VisitDetails visitDetails;
  final FeedbackDetail feedback;
  final AdminWorkflow adminWorkflow;
  final DateTime? createdAt;

  const Feedbacks({
    required this.patientId,
    required this.personalInfo,
    required this.contact,
    required this.visitDetails,
    required this.feedback,
    required this.adminWorkflow,
    this.id,
    this.createdAt,
  });

  factory Feedbacks.fromJson(Map<String, dynamic> json) => Feedbacks(
    id: json['_id'] != null
        ? (json['_id'] is ObjectId
            ? (json['_id'] as ObjectId).oid
            : json['_id'].toString())
        : (json['id'] as String?),
    patientId: json['patientId'] is ObjectId
        ? (json['patientId'] as ObjectId).oid
        : json['patientId'].toString(),
    personalInfo: FeedbackPersonalInfo.fromJson(
      json['personalInfo'] as Map<String, dynamic>,
    ),
    contact: FeedbackContact.fromJson(
      json['contact'] as Map<String, dynamic>,
    ),
    visitDetails: VisitDetails.fromJson(
      json['visitDetails'] as Map<String, dynamic>,
    ),
    feedback: FeedbackDetail.fromJson(
      json['feedback'] as Map<String, dynamic>,
    ),
    adminWorkflow: AdminWorkflow.fromJson(
      json['adminWorkflow'] as Map<String, dynamic>,
    ),
    createdAt: json['createdAt'] is DateTime
        ? json['createdAt'] as DateTime
        : (json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null),
  );

  Map<String, dynamic> toDocument() => {
    'patientId': _toObjectId(patientId) ?? patientId,
    'personalInfo': personalInfo.toDocument(),
    'contact': contact.toJson(),
    'visitDetails': visitDetails.toDocument(),
    'feedback': feedback.toJson(),
    'adminWorkflow': adminWorkflow.toDocument(),
    'createdAt': createdAt ?? DateTime.now().toUtc(),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'personalInfo': personalInfo.toJson(),
    'contact': contact.toJson(),
    'visitDetails': visitDetails.toJson(),
    'feedback': feedback.toJson(),
    'adminWorkflow': adminWorkflow.toJson(),
    'createdAt': createdAt?.toIso8601String(),
  };
}

class FeedbackPersonalInfo {
  final String firstName;
  final String lastName;
  final DateTime? dob;
  final String nationality;
  final String role;

  const FeedbackPersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.role,
    this.dob,
  });

  factory FeedbackPersonalInfo.fromJson(Map<String, dynamic> json) =>
      FeedbackPersonalInfo(
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        nationality: json['nationality'] as String? ?? '',
        role: json['role'] as String? ?? 'patient',
        dob: json['dob'] is DateTime
            ? json['dob'] as DateTime
            : (json['dob'] != null
                ? DateTime.tryParse(json['dob'].toString())
                : null),
      );

  Map<String, dynamic> toDocument() => {
    'firstName': firstName,
    'lastName': lastName,
    'nationality': nationality,
    'role': role,
    if (dob != null) 'dob': dob,
  };

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'nationality': nationality,
    'role': role,
    'dob': dob?.toIso8601String(),
  };
}

class FeedbackContact {
  final String phoneNumber;
  final String email;
  final bool responseRequired;

  const FeedbackContact({
    required this.phoneNumber,
    required this.email,
    required this.responseRequired,
  });

  factory FeedbackContact.fromJson(Map<String, dynamic> json) =>
      FeedbackContact(
        phoneNumber: json['phoneNumber'] as String? ?? '',
        email: json['email'] as String? ?? '',
        responseRequired: json['responseRequired'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'email': email,
    'responseRequired': responseRequired,
  };
}

class VisitDetails {
  final String clinicId;
  final String clinicName;

  const VisitDetails({
    required this.clinicId,
    required this.clinicName,
  });

  factory VisitDetails.fromJson(Map<String, dynamic> json) => VisitDetails(
    clinicId: json['clinicId'] is ObjectId
        ? (json['clinicId'] as ObjectId).oid
        : json['clinicId'].toString(),
    clinicName: json['clinicName'] as String? ?? '',
  );

  Map<String, dynamic> toDocument() => {
    'clinicId': _toObjectId(clinicId) ?? clinicId,
    'clinicName': clinicName,
  };

  Map<String, dynamic> toJson() => {
    'clinicId': clinicId,
    'clinicName': clinicName,
  };
}

class FeedbackDetail {
  final String type;
  final String title;
  final String message;

  const FeedbackDetail({
    required this.type,
    required this.title,
    required this.message,
  });

  factory FeedbackDetail.fromJson(Map<String, dynamic> json) => FeedbackDetail(
    type: json['type'] as String? ?? 'general',
    title: json['title'] as String? ?? '',
    message: json['message'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'message': message,
  };
}

class AdminWorkflow {
  final String status;
  final String priority;
  final String? assignedStaffId;
  final List<String> internalNotes;

  const AdminWorkflow({
    this.status = 'pending',
    this.priority = 'normal',
    this.internalNotes = const [],
    this.assignedStaffId,
  });

  factory AdminWorkflow.fromJson(Map<String, dynamic> json) => AdminWorkflow(
    status: json['status'] as String? ?? 'pending',
    priority: json['priority'] as String? ?? 'normal',
    assignedStaffId: json['assignedStaffId'] != null
        ? (json['assignedStaffId'] is ObjectId
            ? (json['assignedStaffId'] as ObjectId).oid
            : json['assignedStaffId'].toString())
        : null,
    internalNotes: (json['internalNotes'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
  );

  Map<String, dynamic> toDocument() => {
    'status': status,
    'priority': priority,
    if (assignedStaffId != null)
      'assignedStaffId': _toObjectId(assignedStaffId) ?? assignedStaffId,
    'internalNotes': internalNotes,
  };

  Map<String, dynamic> toJson() => {
    'status': status,
    'priority': priority,
    'assignedStaffId': assignedStaffId,
    'internalNotes': internalNotes,
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
