

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

  const Packages({
    required this.title,
    required this.price,
    required this.currency,
    required this.posterUrl,
    required this.isLimitedOffer,
    required this.isActive,
    required this.inclusions,
    required this.metadata,
    this.id,
    this.createdAt,
  });

  factory Packages.fromJson(Map<String, dynamic> json) => Packages(
    id: json['id'] as String?,
    title: json['title'] as String,
    price: (json['price'] as num).toDouble(),
    currency: Currency.values.byName(json['currency'] as String),
    posterUrl: json['posterUrl'] as String,
    isLimitedOffer: json['isLimitedOffer'] as bool,
    isActive: json['isActive'] as bool,
    inclusions: Inclusions.fromJson(json['inclusions'] as Map<String, dynamic>),
    metadata: Metadata.fromJson(json['metadata'] as Map<String, dynamic>),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'currency': currency.name,
    'posterUrl': posterUrl,
    'isLimitedOffer': isLimitedOffer,
    'isActive': isActive,
    'inclusions': inclusions.toJson(),
    'metadata': metadata.toJson(),
    'createdAt': createdAt?.toIso8601String(),
  };
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
    'ultrasoundsCount': ultrasoundsCount,
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

  const Metadata({
    required this.prepaymentRequired,
    required this.instructions,
    required this.termsAndConditions,
    required this.branchNames,
    required this.supportedBranchIds,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    prepaymentRequired: json['prepaymentRequired'] as bool,
    instructions: json['instructions'] as String,
    termsAndConditions: json['termsAndConditions'] as String,
    branchNames: json['branchNames'] as String,
    supportedBranchIds: (json['supportedBranchIds'] as List)
        .map((e) => e as String)
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'prepaymentRequired': prepaymentRequired,
    'instructions': instructions,
    'termsAndConditions': termsAndConditions,
    'supportedBranchIds': supportedBranchIds,
    'branchNames': branchNames,
  };
}

enum Currency { usd, khr }
