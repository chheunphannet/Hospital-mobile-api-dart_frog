import 'package:mongo_dart/mongo_dart.dart';

class Users {
  final String? id;
  final String email;
  final String phoneNumber;
  final String? passwordHash;
  final String? googleId;
  final String authProvider;
  final String avatarUrl;

  final bool isEmailVerified;

  final PersonalInfo personalInfo;
  final UserRole role;
  final Location location;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Users({
    this.id,
    required this.email,
    required this.phoneNumber,
    this.googleId,
    this.passwordHash,
    required this.authProvider,
    required this.avatarUrl,
    required this.isEmailVerified,
    required this.personalInfo,
    required this.role,
    required this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
    id: (json['_id'] as ObjectId).oid,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
    googleId: json['googleId'] as String,
    authProvider: json['authProvider'] as String,
    avatarUrl: json['avatarUrl'] as String,
    isEmailVerified: json['isEmailVerified'] as bool,
    passwordHash: json['passwordHash'] as String,
    personalInfo: PersonalInfo.fromJson(
      json['personalInfo'] as Map<String, dynamic>,
    ),

    role: UserRole.values.byName((json['role'] as String).toLowerCase()),
    location: Location.fromJson(json['location'] as Map<String, dynamic>),

    createdAt: json['createdAt'] as DateTime,
    updatedAt: json['updatedAt'] as DateTime,
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'googleId': googleId,
      'authProvider': authProvider,
      'avatarUrl': avatarUrl,
      'isEmailVerified': isEmailVerified,
      'personalInfo': personalInfo.toJson(),
      'role': role.name,
      'location': location.toJson(),
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
