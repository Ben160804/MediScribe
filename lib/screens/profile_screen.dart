import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/translation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;
  bool _isBengali = false;
  Map<String, String> _translatedTexts = {};

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return {};

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

    if (doc.exists) {
      return doc.data() ?? {};
    }
    return {};
  }

  Future<void> _toggleTranslation() async {
    setState(() {
      _isBengali = !_isBengali;
    });
  }

  Future<String> _getTranslatedText(String text) async {
    if (!_isBengali) return text;

    if (!_translatedTexts.containsKey(text)) {
      final translated = await TranslationService.translateToBengali(text);
      _translatedTexts[text] = translated;
    }
    return _translatedTexts[text]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getTranslatedText("Profile"),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? "Profile");
          },
        ),
        backgroundColor: const Color(0xFF7E57C2),
        actions: [
          IconButton(
            icon: Icon(_isBengali ? Icons.translate : Icons.translate_outlined),
            onPressed: _toggleTranslation,
            tooltip: _isBengali ? "Switch to English" : "Switch to Bengali",
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: FutureBuilder<String>(
                future: _getTranslatedText("Loading..."),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Loading...",
                    style: GoogleFonts.roboto(fontSize: 16),
                  );
                },
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: FutureBuilder<String>(
                future: _getTranslatedText("Error loading profile"),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Error loading profile",
                    style: GoogleFonts.roboto(fontSize: 16),
                  );
                },
              ),
            );
          }

          final userData = snapshot.data ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: _getTranslatedText("Personal Information"),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? "Personal Information",
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow("Name", userData['name'] ?? 'Not set'),
                        _buildInfoRow("Email", userData['email'] ?? 'Not set'),
                        _buildInfoRow("Phone", userData['phone'] ?? 'Not set'),
                        _buildInfoRow(
                          "Age",
                          userData['age']?.toString() ?? 'Not set',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: _getTranslatedText("Test History Summary"),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? "Test History Summary",
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (userData['labHistory'] != null)
                          ...(userData['labHistory'] as Map<String, dynamic>)
                              .keys
                              .map(
                                (testName) => _buildTestSummary(
                                  testName,
                                  (userData['labHistory'][testName] as List)
                                      .length,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (userData['doctorConsultation'] != null)
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<String>(
                            future: _getTranslatedText(
                              "Doctor's Recommendation",
                            ),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "Doctor's Recommendation",
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildConsultationInfo(
                            userData['doctorConsultation'],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: FutureBuilder<String>(
              future: _getTranslatedText(label),
              builder: (context, snapshot) {
                return Text(
                  "${snapshot.data ?? label}:",
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.roboto())),
        ],
      ),
    );
  }

  Widget _buildTestSummary(String testName, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _getTranslatedText(testName),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? testName,
                  style: GoogleFonts.roboto(),
                );
              },
            ),
          ),
          FutureBuilder<String>(
            future: _getTranslatedText("$count tests"),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "$count tests",
                style: GoogleFonts.roboto(color: Colors.grey[600]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationInfo(Map<String, dynamic> consultation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          "Recommendation",
          consultation['recommended'] == true
              ? "Recommended"
              : "Not Recommended",
        ),
        if (consultation['reason'] != null && consultation['reason'].isNotEmpty)
          _buildInfoRow("Reason", consultation['reason']),
        if (consultation['questions'] != null &&
            consultation['questions'].isNotEmpty) ...[
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _getTranslatedText("Questions to Discuss:"),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? "Questions to Discuss:",
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 8),
          ...(consultation['questions'] as List).map(
            (question) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: FutureBuilder<String>(
                future: _getTranslatedText(question),
                builder: (context, snapshot) {
                  return Text(
                    "• ${snapshot.data ?? question}",
                    style: GoogleFonts.roboto(),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
