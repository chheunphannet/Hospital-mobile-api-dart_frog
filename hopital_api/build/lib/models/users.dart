import 'package:mongo_dart/mongo_dart.dart';

class Users {
  final String? id;
  final String email;
  final String? phoneNumber;
  final String? passwordHash;
  final String? googleId;
  final String authProvider; // 'local' or 'google'
  final String? avatarUrl;

  final bool isEmailVerified;
  final bool isProfileCompleted;

  final PersonalInfo? personalInfo;
  final UserRole role; //have default
  final Location? location;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Users({
    this.id,
    required this.email,
    this.isProfileCompleted = false,
    this.phoneNumber,
    this.googleId,
    this.passwordHash,
    this.authProvider = 'local',
    this.avatarUrl,
    this.isEmailVerified = false,
    this.personalInfo,
    this.role = UserRole.patient,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    id: json['_id'] != null ? (json['_id'] as ObjectId).oid : null,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    googleId: json['googleId'] as String?,
    authProvider: json['authProvider'] as String? ?? 'local',
    avatarUrl: json['avatarUrl'] as String?,
    isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    isProfileCompleted: json['isProfileCompleted'] as bool? ?? false,
    passwordHash: json['passwordHash'] as String?,
    personalInfo: json['personalInfo'] != null
        ? PersonalInfo.fromJson(
            json['personalInfo'] as Map<String, dynamic>,
          )
        : null,

    role: json['role'] != null
        ? UserRole.values.byName((json['role'] as String).toLowerCase())
        : UserRole.patient,
    location: json['location'] != null
        ? Location.fromJson(json['location'] as Map<String, dynamic>)
        : null,
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

  Map<String, dynamic> toDocument() {
    return {
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (passwordHash != null) 'passwordHash': passwordHash,
      if (googleId != null) 'googleId': googleId,
      'authProvider': authProvider,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'isEmailVerified': isEmailVerified,
      'isProfileCompleted': isProfileCompleted,
      if (personalInfo != null) 'personalInfo': personalInfo?.toJson(),
      'role': role.name,
      if (location != null) 'location': location?.toJson(),
      'createdAt': createdAt ?? DateTime.now().toUtc(),
      'updatedAt': updatedAt ?? DateTime.now().toUtc(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'googleId': googleId,
      'authProvider': authProvider,
      'avatarUrl': avatarUrl,
      'isEmailVerified': isEmailVerified,
      'isProfileCompleted': isProfileCompleted,
      'personalInfo': personalInfo?.toJson(),
      'role': role.name,
      'location': location?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PersonalInfo {
  const PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.nationality,
    required this.maritalStatus,
  });

  final String firstName;
  final String lastName;
  final DateTime? dob;
  final String gender;
  final String nationality;
  final String maritalStatus;

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    dob: DateTime.parse(json['dob'] as String),
    gender: json['gender'] as String,
    nationality: json['nationality'] as String,
    maritalStatus: json['maritalStatus'] as String,
  );

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'nationality': nationality,
      'maritalStatus': maritalStatus,
    };
  }
}

class Location {
  final String address;
  final String city;

  const Location({required this.address, required this.city});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    address: json['address'] as String,
    city: json['city'] as String,
  );

  Map<String, dynamic> toJson() => {'address': address, 'city': city};
}

enum UserRole { patient, doctor, admin }
