import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/check.dart';

abstract class MediaAnalysisService {
  Future<Verdict> analyze(XFile file, Verdict sample);
}

/// Presentation only: never infers a verdict from file contents.
class DemoAnalysisService implements MediaAnalysisService {
  @override
  Future<Verdict> analyze(XFile file, Verdict sample) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) throw Exception('empty');
    await Future<void>.delayed(const Duration(seconds: 2));
    return sample;
  }
}

class LocalStore {
  final SharedPreferences prefs;
  LocalStore(this.prefs);
  List<Check> read() {
    try {
      return (jsonDecode(prefs.getString('history') ?? '[]') as List)
          .map((e) => Check.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Check> checks) async {
    await prefs.setString(
      'history',
      jsonEncode(checks.map((e) => e.toJson()).toList()),
    );
  }
}

/// Explainable local rules, not a model or news fact checker.
List<String> messageSignals(String text) {
  final t = text.toLowerCase();
  final found = <String>[];
  if (RegExp(
    r'urgent|immediately|act now|segera|sekarang|hari ini|within \d+',
  ).hasMatch(t)) {
    found.add('urgency');
  }
  if (RegExp(
    r'transfer|bank|payment|bayar|wang|duit|money|hadiah|prize',
  ).hasMatch(t)) {
    found.add('money');
  }
  if (RegExp(
    r'password|otp|pin\b|ic number|identity|kata laluan|kad pengenalan|personal details',
  ).hasMatch(t)) {
    found.add('personal');
  }
  if (RegExp(r'bit\.ly|tinyurl\.com|t\.co/|shorturl|is\.gd').hasMatch(t)) {
    found.add('short');
  }
  if (RegExp(r'https?://').hasMatch(t)) found.add('link');
  return found;
}
