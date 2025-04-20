import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/lab_result_entry_model.dart';

class LabReportScreen extends StatelessWidget {
  final Map<String, List<LabResultEntry>> labHistory;

  const LabReportScreen({super.key, required this.labHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Report Analysis"),
        backgroundColor: const Color(0xFF7E57C2),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: labHistory.length,
        itemBuilder: (context, index) {
          final testName = labHistory.keys.elementAt(index);
          final entries = labHistory[testName]!;

          // Sort entries by date in descending order (newest first)
          entries.sort((a, b) => b.date.compareTo(a.date));

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(
                testName,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              children:
                  entries
                      .map(
                        (entry) => ListTile(
                          title: Text(
                            "Date: ${entry.date.day}/${entry.date.month}/${entry.date.year}",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Value: ${entry.value} ${entry.unit ?? ''}"),
                              Text("Normal Range: ${entry.normalRange}"),
                              Text("Status: ${entry.status}"),
                              if (entry.notes != null &&
                                  entry.notes!.isNotEmpty)
                                Text("Notes: ${entry.notes}"),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          );
        },
      ),
    );
  }
}
