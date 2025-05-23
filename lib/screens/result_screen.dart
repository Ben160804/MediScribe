import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user_model.dart';
import '../models/lab_result_entry_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/translation_service.dart';
import '../screens/profile_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<UserModel?> _userFuture;
  late StreamSubscription<UserModel?>? _userSubscription;
  bool _isBengali = false;
  Map<String, String> _translatedTexts = {};

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
    _setupUserSubscription();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
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

  void _setupUserSubscription() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromDoc(doc) : null)
        .listen((user) {
          if (user != null) {
            setState(() {
              _userFuture = Future.value(user);
            });
          }
        });
  }

  Future<UserModel?> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

    if (doc.exists) {
      return UserModel.fromDoc(doc);
    }
    return null;
  }

  Future<List<LabResultEntry>> _getPreviousResults(String testType) async {
    final user = Provider.of<UserModel>(context, listen: false);
    final results = user.labResults[testType] ?? [];
    return results
        .where((entry) => entry.date.isBefore(DateTime.now()))
        .toList();
  }

  Future<Map<String, dynamic>> _getSummaryData(String testType) async {
    final user = Provider.of<UserModel>(context, listen: false);
    return user.summary[testType] ?? {};
  }

  double _calculateMinValue(List<String> values) {
    return values
        .map((v) => double.tryParse(v) ?? 0.0)
        .reduce((a, b) => a < b ? a : b);
  }

  double _calculateMaxValue(List<String> values) {
    return values
        .map((v) => double.tryParse(v) ?? 0.0)
        .reduce((a, b) => a > b ? a : b);
  }

  double _calculateRange(double maxValue, double minValue) {
    return maxValue - minValue;
  }

  Widget _buildTestGraph(String testName, List<LabResultEntry> entries) {
    // Sort entries by date
    final sortedEntries = entries.toList();
    sortedEntries.sort((a, b) => a.date.compareTo(b.date));

    // Extract values for the graph
    final values = sortedEntries.map((e) => e.value).toList();
    final minValue = _calculateMinValue(values);
    final maxValue = _calculateMaxValue(values);
    final range = _calculateRange(maxValue, minValue);
    final padding = range * 0.1; // 10% padding

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getTranslatedText(testName),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ?? testName,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _getTranslatedText(
                "Normal Range: ${sortedEntries.last.normalRange}",
              ),
              builder: (context, snapshot) {
                return Text(
                  snapshot.data ??
                      "Normal Range: ${sortedEntries.last.normalRange}",
                  style: GoogleFonts.roboto(fontSize: 14),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: GoogleFonts.roboto(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < sortedEntries.length) {
                            final date = sortedEntries[index].date;
                            return Text(
                              '${date.day}/${date.month}',
                              style: GoogleFonts.roboto(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: minValue - padding,
                  maxY: maxValue + padding,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        sortedEntries.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          double.parse(sortedEntries[index].value),
                        ),
                      ),
                      isCurved: true,
                      color: _getTrendColor(_calculateTrend(sortedEntries)),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getTrendColor(
                          _calculateTrend(sortedEntries),
                        ).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<String>(
                  future: _getTranslatedText(
                    "Latest Value: ${sortedEntries.last.value} ${sortedEntries.last.unit ?? ''}",
                  ),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ??
                          "Latest Value: ${sortedEntries.last.value} ${sortedEntries.last.unit ?? ''}",
                      style: GoogleFonts.roboto(fontSize: 14),
                    );
                  },
                ),
                FutureBuilder<String>(
                  future: _getTranslatedText(
                    "Trend: ${_calculateTrend(sortedEntries)}",
                  ),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ??
                          "Trend: ${_calculateTrend(sortedEntries)}",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: _getTrendColor(_calculateTrend(sortedEntries)),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: _userFuture.then((user) => user?.summary[testName] ?? {}),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final summary = snapshot.data!;
                  final consultation = summary['doctorConsultation'];

                  if (consultation != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<String>(
                          future: _getTranslatedText("Doctor's Recommendation"),
                          builder: (context, snapshot) {
                            return Text(
                              snapshot.data ?? "Doctor's Recommendation",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        if (consultation['recommended'] == true)
                          FutureBuilder<String>(
                            future: _getTranslatedText(
                              "Consultation Recommended",
                            ),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "Consultation Recommended",
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                        if (consultation['reason'] != null &&
                            consultation['reason'].isNotEmpty) ...[
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: _getTranslatedText(
                              "Reason: ${consultation['reason']}",
                            ),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ??
                                    "Reason: ${consultation['reason']}",
                                style: GoogleFonts.roboto(fontSize: 14),
                              );
                            },
                          ),
                        ],
                        if (consultation['questions'] != null &&
                            consultation['questions'].isNotEmpty) ...[
                          const SizedBox(height: 8),
                          FutureBuilder<String>(
                            future: _getTranslatedText("Questions to Discuss:"),
                            builder: (context, snapshot) {
                              return Text(
                                snapshot.data ?? "Questions to Discuss:",
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          ...(consultation['questions'] as List).map(
                            (question) => Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                bottom: 4,
                              ),
                              child: FutureBuilder<String>(
                                future: _getTranslatedText(question),
                                builder: (context, snapshot) {
                                  return Text(
                                    "• ${snapshot.data ?? question}",
                                    style: GoogleFonts.roboto(fontSize: 14),
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
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTrend(List<LabResultEntry> entries) {
    if (entries.length < 2) return 'Insufficient data';

    final recentValues = entries.sublist(entries.length - 2);
    final value1 = double.parse(recentValues[0].value);
    final value2 = double.parse(recentValues[1].value);
    final difference = value2 - value1;

    if (difference > 0) return 'Increasing';
    if (difference < 0) return 'Decreasing';
    return 'Stable';
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'increasing':
        return Colors.green;
      case 'decreasing':
        return Colors.red;
      case 'stable':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getTranslatedText("Test Results History"),
          builder: (context, snapshot) {
            return Text(snapshot.data ?? "Test Results History");
          },
        ),
        backgroundColor: const Color(0xFF7E57C2),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Get.to(() => const ProfileScreen());
            },
            tooltip: "View Profile",
          ),
          IconButton(
            icon: Icon(_isBengali ? Icons.translate : Icons.translate_outlined),
            onPressed: _toggleTranslation,
            tooltip: _isBengali ? "Switch to English" : "Switch to Bengali",
          ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
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
                future: _getTranslatedText("Error: ${snapshot.error}"),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "Error: ${snapshot.error}",
                    style: GoogleFonts.roboto(fontSize: 16),
                  );
                },
              ),
            );
          }

          final user = snapshot.data;
          if (user == null || user.labHistory.isEmpty) {
            return Center(
              child: FutureBuilder<String>(
                future: _getTranslatedText("No test results available"),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? "No test results available",
                    style: GoogleFonts.roboto(fontSize: 16),
                  );
                },
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: user.labHistory.length,
            itemBuilder: (context, index) {
              final testName = user.labHistory.keys.elementAt(index);
              final entries = user.labHistory[testName]!;
              return _buildTestGraph(testName, entries);
            },
          );
        },
      ),
    );
  }
}
