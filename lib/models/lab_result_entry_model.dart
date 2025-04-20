class LabResultEntry {
  final double value;
  final String normalRange;
  final String status;
  final DateTime date;
  final String? unit;
  final String? notes;

  LabResultEntry({
    required this.value,
    required this.normalRange,
    required this.status,
    required this.date,
    this.unit,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'normalRange': normalRange,
      'status': status,
      'date': date.toIso8601String(),
      if (unit != null) 'unit': unit,
      if (notes != null) 'notes': notes,
    };
  }

  factory LabResultEntry.fromMap(Map<String, dynamic> map) {
    return LabResultEntry(
      value: (map['value'] as num).toDouble(),
      normalRange: map['normalRange'] as String,
      status: map['status'] as String,
      date: DateTime.parse(map['date'] as String),
      unit: map['unit'] as String?,
      notes: map['notes'] as String?,
    );
  }
}
