import 'package:hopital_api/models/branches.dart';
import 'package:hopital_api/models/clinics.dart';
import 'package:hopital_api/models/doctors.dart';
import 'package:hopital_api/models/packages.dart';

class ChunkBuilder {
  static String package(Packages p) {
    final i = p.inclusions;
    return '''
        Health package: ${p.title}
        Price: ${p.price} ${p.currency.name.toUpperCase()}
        Available at: ${p.metadata.branchNames}
        Includes: ${i.specialistConsultationsCount} specialist consultations, ${i.completeBloodCounts} complete blood counts, ${i.urineAnalysisCount} urine analyses, ${i.ultrasoundsCount} ultrasounds${i.ntScreening ? ', NT screening' : ''}.
        Lab tests: ${i.labTests.join('; ')}.
        Supplements: ${i.supplements}
        Instructions: ${p.metadata.instructions}
        Terms: ${p.metadata.termsAndConditions}
      '''
        .trim();
  }

  static String doctor(
    Doctors d, {
    required String clinicName,
    required List<String> branchNames,
  }) =>
      '''
        Doctor: ${d.name}
        Title: ${d.title ?? 'Specialist'}
        Clinic: $clinicName
        Works at: ${branchNames.join(', ')}
        Languages: ${d.languagesSpoken.join(', ')}
        Qualifications: ${d.qualifications.join('; ')}
        About: ${d.bio}
        Available for booking: ${d.isAvailableForBooking ? 'yes' : 'no'}'''
          .trim();

  static String clinic(Clinics c, {required List<String> branchNames}) =>
      '''
        Clinic: ${c.name}
        Description: ${c.description}
        Available at: ${branchNames.join(', ')}
      '''
          .trim();

  static String branch(Branches b) {
    final equipment = b.hardwares.isNotEmpty
        ? b.hardwares.map((h) => h.name).join(', ')
        : 'General medical equipment';
    final rooms = b.rooms.isNotEmpty
        ? b.rooms.map((r) => r.type).join(', ')
        : 'Standard rooms';

    return '''
        Branch: ${b.name} (${b.code})
        Address: ${b.address}
        Phone: ${b.contactNumbers.join(', ')}
        Email: ${b.email}
        Equipment: $equipment
        Rooms: $rooms
      '''
        .trim();
  }

  static String contentBlock({
    required String kind,
    required String title,
    required String text,
    String? clinic,
    String? caption,
  }) =>
      '''
      $kind: $title
      ${clinic != null && clinic.isNotEmpty ? 'Clinic: $clinic\n' : ''}${caption != null && caption.isNotEmpty ? 'Topic: $caption\n' : ''}$text
      '''
          .trim();
}
