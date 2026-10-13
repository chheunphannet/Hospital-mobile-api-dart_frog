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
    id: json['id'] as String?,
    patientId: json['patientId'] as String,
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
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );

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
        nationality: json['nationality'] as String,
        role: json['role'] as String,
        dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
      );

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
        phoneNumber: json['phoneNumber'] as String,
        email: json['email'] as String,
        responseRequired: json['responseRequired'] as bool,
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
    clinicId: json['clinicId'] as String,
    clinicName: json['clinicName'] as String,
  );

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
    type: json['type'] as String,
    title: json['title'] as String,
    message: json['message'] as String,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'title': title,
    'message': message,
  };
}

class AdminWorkflow {
  final String status; //"pending"  "in_progress"  "resolved"
  final String priority; //Knows what to fix first
  final String? assignedStaffId;
  final List<String> internalNotes; //Notes between staff like

  const AdminWorkflow({
    required this.status,
    required this.priority,
    required this.internalNotes,
    this.assignedStaffId,
  });

  factory AdminWorkflow.fromJson(Map<String, dynamic> json) => AdminWorkflow(
    status: json['status'] as String,
    priority: json['priority'] as String,
    assignedStaffId: json['assignedStaffId'] as String?,
    internalNotes: (json['internalNotes'] as List)
        .map((e) => e as String)
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'priority': priority,
    'assignedStaffId': assignedStaffId,
    'internalNotes': internalNotes,
  };
}
