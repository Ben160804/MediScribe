import 'package:cloud_firestore/cloud_firestore.dart';
import 'lab_result_entry_model.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;

  final Map<String, List<LabResultEntry>> labHistory;

  /// Summary per test (e.g., trend, latest value, status)
  final Map<String, dynamic> summary;

  /// Getter for labResults (alias for labHistory)
  Map<String, List<LabResultEntry>> get labResults => labHistory;

  /// Doctor consultation recommendation
  final DoctorConsultation? doctorConsultation;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    Map<String, List<LabResultEntry>>? labHistory,
    Map<String, dynamic>? summary,
    this.doctorConsultation,
  }) : labHistory = labHistory ?? {},
       summary = summary ?? {};

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'labHistory': labHistory.map(
        (test, entries) =>
            MapEntry(test, entries.map((e) => e.toMap()).toList()),
      ),
      'summary': summary,
      'doctorConsultation': doctorConsultation?.toMap(),
    };
  }

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawLab = data['labHistory'] as Map<String, dynamic>? ?? {};
    final parsedLab = rawLab.map((test, rawEntries) {
      final list =
          (rawEntries as List)
              .map((e) => LabResultEntry.fromMap(e as Map<String, dynamic>))
              .toList();
      return MapEntry(test, list);
    });

    return UserModel(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'] ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      labHistory: parsedLab,
      summary: (data['summary'] as Map<String, dynamic>? ?? {}),
      doctorConsultation:
          data['doctorConsultation'] != null
              ? DoctorConsultation.fromMap(data['doctorConsultation'])
              : null,
    );
  }
}

class DoctorConsultation {
  final bool recommended;
  final String reason;
  final List<String> questions;

  DoctorConsultation({
    required this.recommended,
    required this.reason,
    List<String>? questions,
  }) : questions = questions ?? [];

  Map<String, dynamic> toMap() {
    return {
      'recommended': recommended,
      'reason': reason,
      'questions': questions,
    };
  }

  factory DoctorConsultation.fromMap(Map<String, dynamic> map) {
    return DoctorConsultation(
      recommended: map['recommended'] as bool? ?? false,
      reason: map['reason'] as String? ?? '',
      questions: List<String>.from(map['questions'] as List<dynamic>? ?? []),
    );
  }
}
