import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/script_model.dart';
import 'package:uuid/uuid.dart';

class ScriptController extends GetxController {
  static const _scriptsKey = 'user_scripts';
  var scripts = <Script>[].obs; // Observable list for reactive UI updates
  final Uuid _uuid = Uuid();

  @override
  void onInit() {
    super.onInit();
    loadScripts();
  }

  Future<void> loadScripts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scriptsJson = prefs.getString(_scriptsKey);
    if (scriptsJson != null) {
      final List<dynamic> decodedJson = jsonDecode(scriptsJson) as List<dynamic>;
      scripts.value = decodedJson
          .map((jsonItem) => Script.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
      // Sort by creation date, newest first
      scripts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Future<void> addScript(String title, String content) async {
    if (title.isEmpty) {
      Get.snackbar('Error', 'Title cannot be empty.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (content.isEmpty) {
      Get.snackbar('Error', 'Content cannot be empty.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final newScript = Script(
      id: _uuid.v4(), // Generate a unique ID
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    scripts.insert(0, newScript); // Add to the beginning of the list for newest first display
    await _saveScriptsToPrefs();
    Get.snackbar('Success', 'Script saved successfully!', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> deleteScript(String scriptId) async {
    scripts.removeWhere((script) => script.id == scriptId);
    await _saveScriptsToPrefs();
    Get.snackbar('Success', 'Script deleted successfully!', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> updateScript(Script updatedScript) async {
    final index = scripts.indexWhere((script) => script.id == updatedScript.id);
    if (index != -1) {
      scripts[index] = updatedScript;
      // Ensure list remains sorted if modification affects order (e.g. if createdAt can be changed)
      // scripts.sort((a, b) => b.createdAt.compareTo(a.createdAt)); 
      await _saveScriptsToPrefs();
      Get.snackbar('Success', 'Script updated successfully!', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'Script not found for update.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _saveScriptsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedJson = jsonEncode(scripts.map((script) => script.toJson()).toList());
    await prefs.setString(_scriptsKey, encodedJson);
  }
}
