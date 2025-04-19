import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DynamicTranslations extends Translations {
  final Map<String, Map<String, String>> _translations = {};

  DynamicTranslations();

  Future<void> loadTranslations() async {
    final locales = ['en', 'bn'];

    for (String locale in locales) {
      String jsonString = await rootBundle.loadString('assets/lang/$locale.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _translations[locale] = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    }
  }

  @override
  Map<String, Map<String, String>> get keys => _translations;
}
