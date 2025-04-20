class LabResultEntry {
  final DateTime date;
  final String value;
  final String? unit;
  final String normalRange;
  final String status;
  final String? notes;

  LabResultEntry({
    required this.date,
    required this.value,
    this.unit,
    required this.normalRange,
    required this.status,
    this.notes,
  });

  factory LabResultEntry.fromJson(Map<String, dynamic> json) {
    return LabResultEntry(
      date: DateTime.parse(json['date']),
      value: json['value'].toString(),
      unit: json['unit'],
      normalRange: json['normalRange'],
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'unit': unit,
      'normalRange': normalRange,
      'status': status,
      'notes': notes,
    };
  }

  // For backward compatibility
  factory LabResultEntry.fromMap(Map<String, dynamic> map) {
    return LabResultEntry(
      date: DateTime.parse(map['date']),
      value: map['value'].toString(),
      unit: map['unit'],
      normalRange: map['normalRange'],
      status: map['status'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'unit': unit,
      'normalRange': normalRange,
      'status': status,
      'notes': notes,
    };
  }
}
