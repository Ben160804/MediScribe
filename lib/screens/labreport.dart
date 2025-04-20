import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/lab_result_entry_model.dart';

class LabReportScreen extends StatefulWidget {
  final Map<String, List<LabResultEntry>>? labHistory;

  const LabReportScreen({super.key, this.labHistory});

  @override
  State<LabReportScreen> createState() => _LabReportScreenState();
}

class _LabReportScreenState extends State<LabReportScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Map<String, List<LabResultEntry>> labHistory;

  @override
  void initState() {
    super.initState();
    labHistory = widget.labHistory ?? {};
    if (labHistory.isEmpty) {
      _fetchLabReports();
    }
  }

  Future<void> _fetchLabReports() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('lab_reports')
              .get();

      Map<String, List<LabResultEntry>> tempHistory = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final testName = data['testName'] as String;
        final entry = LabResultEntry(
          date: (data['date'] as Timestamp).toDate(),
          value: data['value'].toString(),
          unit: data['unit'] as String?,
          normalRange: data['normalRange'] as String,
          status: data['status'] as String,
          notes: data['notes'] as String?,
        );

        if (!tempHistory.containsKey(testName)) {
          tempHistory[testName] = [];
        }
        tempHistory[testName]!.add(entry);
      }

      setState(() {
        labHistory = tempHistory;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch lab reports: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lab Report Analysis"),
        backgroundColor: const Color(0xFF7E57C2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLabReports,
            tooltip: 'Refresh Reports',
          ),
        ],
      ),
      body:
          labHistory.isEmpty
              ? const Center(
                child: Text(
                  'No lab reports found',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Value: ${entry.value} ${entry.unit ?? ''}",
                                      ),
                                      Text(
                                        "Normal Range: ${entry.normalRange}",
                                      ),
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
