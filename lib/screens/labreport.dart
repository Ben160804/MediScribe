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

class _LabReportScreenState extends State<LabReportScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Map<String, List<LabResultEntry>> labHistory;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    labHistory = widget.labHistory ?? {};
    if (labHistory.isEmpty) {
      _fetchLabReports();
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'high':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lab Report Analysis",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF7E57C2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLabReports,
            tooltip: 'Refresh Reports',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child:
            labHistory.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No lab reports found',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload a new report or check back later',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: labHistory.length,
                  itemBuilder: (context, index) {
                    final testName = labHistory.keys.elementAt(index);
                    final entries = labHistory[testName]!;

                    // Sort entries by date in descending order (newest first)
                    entries.sort((a, b) => b.date.compareTo(a.date));

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          testName,
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(
                            entries.first.status,
                          ),
                          child: Icon(
                            Icons.medical_services,
                            color: Colors.white,
                          ),
                        ),
                        children:
                            entries
                                .map(
                                  (entry) => Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey[200]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        "Date: ${entry.date.day}/${entry.date.month}/${entry.date.year}",
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.science,
                                                size: 16,
                                                color: _getStatusColor(
                                                  entry.status,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Value: ${entry.value} ${entry.unit ?? ''}",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.trending_up,
                                                size: 16,
                                                color: Colors.blue,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Normal Range: ${entry.normalRange}",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: _getStatusColor(
                                                  entry.status,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Status: ${entry.status}",
                                                style: GoogleFonts.roboto(
                                                  fontSize: 14,
                                                  color: _getStatusColor(
                                                    entry.status,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (entry.notes != null &&
                                              entry.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.note,
                                                  size: 16,
                                                  color: Colors.orange,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    "Notes: ${entry.notes}",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
