import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learner_model.dart';
import '../models/profile.dart';

class UserProgressStore {
  static const _prefix = 'learner_model_';

  static Future<void> save(LearnerModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefix + model.userId, jsonEncode(model.toJson()));
  }

  static Future<LearnerModel?> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefix + userId);
    if (json == null) return null;
    return LearnerModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  static Future<LearnerModel> loadOrCreate(Profile profile) async {
    final existing = await load(profile.name);
    if (existing != null) {
      existing.lastActive = DateTime.now();
      await save(existing);
      return existing;
    }
    final model = LearnerModel(userId: profile.name);
    await save(model);
    return model;
  }

  static Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefix + userId);
  }
}
