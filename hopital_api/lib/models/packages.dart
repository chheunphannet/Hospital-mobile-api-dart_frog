import 'dart:convert';

class Packages {
  final String? id;
  final String title;
  final double price;
  final Currency currency;
  final String posterUrl;
  final bool isLimitedOffer;
  final bool isActive;
  final Inclusions inclusions;
  final Metadata metadata;
  final DateTime? createdAt;
}

class Inclusions {
  //total number of specialist doctor visits
  final int specialistConsultationsCount;
  //total number of Complete Blood Count
  final int completeBloodCounts;
  final List<String> labTests;
  //total number of routine urine tests
  final int urineAnalysisCount;
  //total obstetric ultrasound imaging scans
  final int ultrasoundsCount;
  // is Nuchal Translucency include
  final bool ntScreening;
  //branch type quantity provide to patient
  final String supplements;

  const Inclusions({
    required this.specialistConsultationsCount,
    required this.completeBloodCounts,
    required this.labTests,
    required this.urineAnalysisCount,
    required this.ultrasoundsCount,
    required this.ntScreening,
    required this.supplements,
  });

  factory Inclusions.fromJson(Map<String, dynamic> json) => Inclusions(
    specialistConsultationsCount: json['specialistConsultationsCount'] as int,
    completeBloodCounts: json['completeBloodCounts'] as int,
    labTests: (json['labTests'] as List).map((e) => e as String).toList(),
    urineAnalysisCount: json['urineAnalysisCount'] as int,
    ultrasoundsCount: json['ultrasoundsCount'] as int,
    ntScreening: json['ntScreening'] as bool,
    supplements: json['supplements'] as String,
  );

  Map<String, dynamic> toJson() => {
    'specialistConsultationsCount': specialistConsultationsCount,
    'completeBloodCounts': completeBloodCounts,
    'labTests': labTests,
    'urineAnalysisCount': urineAnalysisCount,
    'ntScreening': ntScreening,
    'supplements': supplements,
  };
}

class Metadata {
  final bool prepaymentRequired;
  final String instructions;
  final String termsAndConditions;
  final String branchNames;
  final List<String> supportedBranchIds;
}

enum Currency { usd, khr }
