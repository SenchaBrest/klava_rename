import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'piano-lib/src/note_position.dart';

class SettingsManager {
  static const String _settingsKeyPrefix = 'settings_';
  static const String _defaultSettingsKey = 'default_settings';
  final Map<String, Set<String>> defaultSettings = {};

  SettingsManager() {
    _init();
  }

  Future<void> _init() async {
    generateDefaultSettings();
    await initializeDefaultSettings();
  }

  void generateDefaultSettings() {
    List<Note> notes = Note.values;
    for (int octave = 0; octave <= 8; octave++) {
      for (Note note in notes) {
        for (Accidental accidental in note.accidentals) {
          if (accidental == Accidental.Flat) {
            continue;
          }
          NotePosition notePosition = NotePosition(note: note, octave: octave, accidental: accidental);
          defaultSettings[notePosition.name] = {};
          if (notePosition.name == 'C8') break;
        }
      }
    }
  }

  Future<void> initializeDefaultSettings() async {
    final allSettingsNames = await getAllSettingsNames();
    if (allSettingsNames.isEmpty) {
      await addDefaultSettings('default');
      await setDefaultSettings('default');
    }
  }

  Future<void> saveSettings(String settingsName, Map<String, Set<String>> settings) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> encodedSettings = settings.entries.map((entry) {
      return {
        'notePosition': entry.key,
        'settings': entry.value.toList(),
      };
    }).toList();
    String jsonSettings = json.encode(encodedSettings);
    await prefs.setString(_settingsKeyPrefix + settingsName, jsonSettings);
  }

  Future<Map<String, Set<String>>> loadSettings(String settingsName) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonSettings = prefs.getString(_settingsKeyPrefix + settingsName);
    if (jsonSettings != null) {
      List<dynamic> decodedList = json.decode(jsonSettings);
      Map<String, Set<String>> settings = {};
      for (var item in decodedList) {
        String notePositionName = item['notePosition'];
        Set<String> settingValues = Set<String>.from(item['settings']);
        settings[notePositionName] = settingValues;
      }
      return settings;
    } else {
      return Map<String, Set<String>>.from(defaultSettings);
    }
  }

  Future<bool> deleteSettings(String settingsName) async {
    final prefs = await SharedPreferences.getInstance();
    final defaultSettingsName = await getDefaultSettingsName();
    if (settingsName == defaultSettingsName) {
      return false;
    }
    final allSettingsNames = await getAllSettingsNames();
    if (allSettingsNames.length > 1) {
      await prefs.remove(_settingsKeyPrefix + settingsName);
    } else {
      return false;
    }
    return true;
  }

  Future<List<String>> getAllSettingsNames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys.where((key) => key.startsWith(_settingsKeyPrefix))
        .map((key) => key.substring(_settingsKeyPrefix.length))
        .toList();
  }

  Set<String>? getSettingsForNote(Map<String, Set<String>> settings, String notePositionName) {
    return settings[notePositionName];
  }

  Set<String> getNotesForSetting(Map<String, Set<String>> settings, String setting) {
    return settings.keys.where((k) => settings[k]!.contains(setting)).toSet();
  }

  void setSettingsForNote(Map<String, Set<String>> settings, String notePositionName, String setting) {
    settings.putIfAbsent(notePositionName, () => <String>{}).add(setting);
  }

  void deleteAllSettingsForNote(Map<String, Set<String>> settings, String notePositionName) {
    settings.remove(notePositionName);
  }

  Future<String> addDefaultSettings(String settingsName) async {
    final allSettingsNames = await getAllSettingsNames();
    while (allSettingsNames.contains(settingsName)) {
      String newSettingsName = incrementNumberAtEnd(settingsName);
      if (settingsName == newSettingsName) {
        settingsName = '$settingsName (1)';
      }
      else {
        settingsName = newSettingsName;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> encodedSettings = defaultSettings.entries.map((entry) {
      return {
        'notePosition': entry.key,
        'settings': entry.value.toList(),
      };
    }).toList();
    String jsonSettings = json.encode(encodedSettings);
    await prefs.setString(_settingsKeyPrefix + settingsName, jsonSettings);

    return settingsName;
  }

  Future<void> setDefaultSettings(String settingsName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultSettingsKey, settingsName);
  }

  Future<String?> getDefaultSettingsName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultSettingsKey);
  }

  Future<Map<String, Set<String>>> loadDefaultSettings() async {
    final defaultSettingsName = await getDefaultSettingsName();
    if (defaultSettingsName != null) {
      return loadSettings(defaultSettingsName);
    } else {
      return Map<String, Set<String>>.from(defaultSettings);
    }
  }

  Future<String> exportSettingsToJsonString(String settingsName) async {
    final settings = await loadSettings(settingsName);
    List<Map<String, dynamic>> encodedSettings = settings.entries.map((entry) {
      return {
        'notePosition': entry.key,
        'settings': entry.value.toList(),
      };
    }).toList();
    return json.encode({
      'settingsName': settingsName,
      'settings': encodedSettings,
    });
  }

  Future<String> importSettingsFromJsonString(String jsonString) async {
    final decodedData = json.decode(jsonString);
    String settingsName = decodedData['settingsName'];
    List<dynamic> settingsList = decodedData['settings'];

    final allSettingsNames = await getAllSettingsNames();
    while (allSettingsNames.contains(settingsName)) {
      String newSettingsName = incrementNumberAtEnd(settingsName);
      if (settingsName == newSettingsName) {
        settingsName = '$settingsName (1)';
      }
      else {
        settingsName = newSettingsName;
      }
    }

    Map<String, Set<String>> settings = {};
    for (var item in settingsList) {
      String notePositionName = item['notePosition'];
      Set<String> settingValues = Set<String>.from(item['settings']);
      settings[notePositionName] = settingValues;
    }
    await saveSettings(settingsName, settings);

    return settingsName;
  }
}

String incrementNumberAtEnd(String input) {
  final regExp = RegExp(r'\s\((\d+)\)$');
  final match = regExp.firstMatch(input);

  if (match != null) {
    final number = int.parse(match.group(1)!);
    final incrementedNumber = number + 1;

    return input.replaceFirst(regExp, ' ($incrementedNumber)');
  }

  return input;
}