import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/labreport.dart';
import '../models/user_model.dart';
import '../models/lab_result_entry_model.dart';
import 'gemini.dart';

// Clean up the raw response safely
String cleanRawJson(String raw) {
  // Remove Markdown code block if present
  if (raw.trim().startsWith('```')) {
    raw = raw.replaceAll('```', '').trim();
  }

  // Remove any newlines and carriage returns
  raw = raw.replaceAll(r'\n', '');
  raw = raw.replaceAll(r'\r', '');

  // Remove any actual newlines and extra spaces
  raw = raw.replaceAll('\n', '');
  raw = raw.replaceAll('\r', '');
  raw = raw.replaceAll(RegExp(r'\s+'), ' ');

  // Remove any remaining backslashes before quotes
  raw = raw.replaceAll(r'\"', '"');

  return raw.trim();
}

// Pretty print in safe chunks for the terminal
void printJsonInChunks(String jsonString, {int chunkSize = 800}) {
  for (int i = 0; i < jsonString.length; i += chunkSize) {
    int end =
        (i + chunkSize < jsonString.length) ? i + chunkSize : jsonString.length;
    print(jsonString.substring(i, end));
  }
}

// Update user document with lab report data
Future<void> updateUserLabReport(Map<String, dynamic> labReport) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user logged in");
      return;
    }

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);

    // First, get the existing lab history
    final docSnapshot = await userDoc.get();
    final existingData = docSnapshot.data();
    final existingLabHistory = <String, List<LabResultEntry>>{};

    if (existingData != null && existingData.containsKey('labHistory')) {
      final rawExistingLab = existingData['labHistory'] as Map<String, dynamic>;
      rawExistingLab.forEach((testName, entries) {
        if (entries is List) {
          existingLabHistory[testName] =
              entries
                  .map((e) => LabResultEntry.fromMap(e as Map<String, dynamic>))
                  .toList();
        }
      });
    }

    // Convert new lab report data
    final Map<String, List<LabResultEntry>> newLabHistory = {};
    final Map<String, dynamic> summary = {};

    if (labReport.containsKey('labHistory')) {
      final rawLabHistory = labReport['labHistory'] as Map<String, dynamic>;
      rawLabHistory.forEach((testName, entries) {
        final List<LabResultEntry> testEntries = [];
        if (entries is List) {
          for (var entry in entries) {
            testEntries.add(
              LabResultEntry(
                value: (entry['value'] as num).toString(),
                normalRange:
                    "${entry['normalRange'][0]} - ${entry['normalRange'][1]}",
                status: entry['status'],
                date: DateTime.now(),
              ),
            );
          }
        }
        newLabHistory[testName] = testEntries;
      });
    }

    // Merge existing and new lab history
    final mergedLabHistory = <String, List<LabResultEntry>>{};

    // Add all existing tests
    existingLabHistory.forEach((testName, entries) {
      mergedLabHistory[testName] = List<LabResultEntry>.from(entries);
    });

    // Add or merge new tests
    newLabHistory.forEach((testName, newEntries) {
      if (mergedLabHistory.containsKey(testName)) {
        // If test exists, append new entries
        mergedLabHistory[testName]!.addAll(newEntries);
      } else {
        // If test is new, add it
        mergedLabHistory[testName] = newEntries;
      }
    });

    // Sort entries by date for each test
    mergedLabHistory.forEach((testName, entries) {
      entries.sort((a, b) => a.date.compareTo(b.date));
    });

    if (labReport.containsKey('summary')) {
      summary.addAll(labReport['summary']);
    }

    DoctorConsultation? doctorConsultation;
    if (labReport.containsKey('doctorConsultation')) {
      final consultation = labReport['doctorConsultation'];
      doctorConsultation = DoctorConsultation(
        recommended: consultation['recommended'] ?? false,
        reason: consultation['reason'] ?? '',
        questions: List<String>.from(consultation['questions'] ?? []),
      );
    }

    // Update the user document with merged data
    await userDoc.update({
      'labHistory': mergedLabHistory.map(
        (test, entries) =>
            MapEntry(test, entries.map((e) => e.toMap()).toList()),
      ),
      'summary': summary,
      'doctorConsultation': doctorConsultation?.toMap(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    print("Successfully updated user's lab report data");
  } catch (e) {
    print("Error updating user's lab report: $e");
  }
}

Future<Map<String, List<LabResultEntry>>> _parseLabResults(
  Map<String, dynamic> data,
) async {
  final Map<String, List<LabResultEntry>> labHistory = {};

  for (var entry in data.entries) {
    final testName = entry.key;
    final entries =
        (entry.value as List)
            .map((e) => LabResultEntry.fromMap(e as Map<String, dynamic>))
            .toList()
            .cast<LabResultEntry>();

    labHistory[testName] = entries;
  }

  return labHistory;
}

LabResultEntry _createLabResultEntry(Map<String, dynamic> entry) {
  return LabResultEntry(
    date: DateTime.parse(entry['date']),
    value: entry['value'].toString(),
    unit: entry['unit'],
    normalRange: entry['normalRange'],
    status: entry['status'],
    notes: entry['notes'],
  );
}

Map<String, List<LabResultEntry>> _convertLabHistory(
  Map<String, dynamic> data,
) {
  final Map<String, List<LabResultEntry>> converted = {};

  for (var entry in data.entries) {
    final testName = entry.key;
    final entries =
        (entry.value as List)
            .map((e) => _createLabResultEntry(e as Map<String, dynamic>))
            .toList()
            .cast<LabResultEntry>();

    converted[testName] = entries;
  }

  return converted;
}

// Upload PDF and process the response
Future<http.Response?> uploadPdf(File pdfFile) async {
  try {
    final uri = Uri.parse('https://backend-mediscribe.onrender.com/upload');

    var request = http.MultipartRequest('POST', uri);
    var stream = http.ByteStream(pdfFile.openRead());
    var length = await pdfFile.length();

    var multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: basename(pdfFile.path),
    );

    request.files.add(multipartFile);

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final rawText = response.body;
      print("\nFull response length: ${rawText.length} characters");

      try {
        // First parse the outer JSON structure
        final outerJson = jsonDecode(rawText);
        print("\nSuccessfully parsed outer JSON structure");

        if (outerJson.containsKey('raw_output')) {
          // Get the raw_output string and clean it
          final rawOutput = outerJson['raw_output'];
          print("\nRaw output length: ${rawOutput.length} characters");

          final cleaned = cleanRawJson(rawOutput);
          print("\nCleaned output length: ${cleaned.length} characters");

          try {
            // Parse the cleaned lab report JSON
            final labReport = jsonDecode(cleaned);
            print("\nSuccessfully parsed lab report JSON");

            // Print the entire lab report in sections
            print("\n=== LAB HISTORY ===");
            if (labReport.containsKey("labHistory")) {
              final labHistory = labReport["labHistory"];
              print("Number of tests: ${labHistory.length}");
              print("Tests: ${labHistory.keys.join(', ')}");
            }

            print("\n=== SUMMARY ===");
            if (labReport.containsKey("summary")) {
              final summary = labReport["summary"];
              print("Number of summarized tests: ${summary.length}");
              print("Summarized tests: ${summary.keys.join(', ')}");
            }

            print("\n=== DOCTOR CONSULTATION ===");
            if (labReport.containsKey("doctorConsultation")) {
              final consultation = labReport["doctorConsultation"];
              print("Consultation recommended: ${consultation["recommended"]}");
              print("Reason: ${consultation["reason"]}");
              print("\nQuestions:");
              if (consultation.containsKey("questions")) {
                final questions = consultation["questions"];
                for (var i = 0; i < questions.length; i++) {
                  print("${i + 1}. ${questions[i]}");
                }
              }
            }

            // Print the full JSON for verification
            print("\n=== FULL REPORT JSON ===");
            final prettyJson = const JsonEncoder.withIndent(
              '  ',
            ).convert(labReport);
            printJsonInChunks(prettyJson);

            if (labReport.containsKey("labHistory")) {
              // Update the user's document with the new lab report data
              await updateUserLabReport(labReport);

              // Convert the lab history to the correct type
              final Map<String, List<LabResultEntry>> convertedLabHistory = {};
              final rawLabHistory =
                  labReport['labHistory'] as Map<String, dynamic>;

              rawLabHistory.forEach((testName, entries) {
                if (entries is List) {
                  convertedLabHistory[testName] =
                      entries
                          .map(
                            (entry) => LabResultEntry(
                              value: (entry['value'] as num).toString(),
                              normalRange:
                                  "${entry['normalRange'][0]} - ${entry['normalRange'][1]}",
                              status: entry['status'],
                              date: DateTime.now(),
                            ),
                          )
                          .toList();
                }
              });

              Get.to(() => LabReportScreen(labHistory: convertedLabHistory));
            } else {
              print("Warning: Lab report does not contain 'labHistory' key");
            }
          } catch (e) {
            print("❌ Failed to parse cleaned lab report: $e");
            print("Cleaned output preview:");
            print(
              cleaned.substring(
                0,
                cleaned.length > 1000 ? 1000 : cleaned.length,
              ),
            );
            if (cleaned.length > 1000) print("... (truncated)");
          }
        } else {
          print("Warning: Response does not contain 'raw_output' field");
          print("Available keys: ${outerJson.keys.join(', ')}");
        }
      } catch (e) {
        print("❌ Failed to parse outer JSON: $e");
        print("Raw text preview:");
        print(
          rawText.substring(0, rawText.length > 1000 ? 1000 : rawText.length),
        );
        if (rawText.length > 1000) print("... (truncated)");
      }
    } else {
      print("Failed to upload PDF. Status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error uploading PDF: $e");
    return null;
  }
}
