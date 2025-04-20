import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LabReportScreen extends StatelessWidget {
  final Map<String, dynamic> labHistory;

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
          final testDetails = labHistory[testName][0]; // only showing first entry

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(
                testName,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Value: ${testDetails['value']}"),
                    Text("Normal Range: ${testDetails['normalRange'][0]} - ${testDetails['normalRange'][1]}"),
                    Text("Status: ${testDetails['status']}"),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
