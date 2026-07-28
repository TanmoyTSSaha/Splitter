import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/Constants/app_keys.dart';
import 'package:splitr/Model/product_category_model.dart';

/// Offline fallback for personal expense category pickers.
class PersonalCategoryCache {
  Future<void> save(List<CategoryOnlyModel> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = categories.map((c) => c.toJSON()).toList();
    await prefs.setString(PrefKeys.personalCategoriesV1, jsonEncode(payload));
  }

  Future<List<CategoryOnlyModel>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(PrefKeys.personalCategoriesV1);
    if (raw == null || raw.isEmpty) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CategoryOnlyModel.fromJSON(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }
}
