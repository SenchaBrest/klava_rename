import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'piano-lib/src/note_position.dart';
import 'package:collection/collection.dart';

class SettingsManager {
  static const String _settingsKeyPrefix = 'settings_';
  final Map<NotePosition, Set<String>> defaultSettings = {};

  SettingsManager() {
    generateDefaultSettings();
  }

  void generateDefaultSettings() {
    List<Note> notes = Note.values;
    for (int octave = 0; octave <= 8; octave++) {
      for (Note note in notes) {
        for (Accidental accidental in note.accidentals) {
          NotePosition notePosition = NotePosition(note: note, octave: octave, accidental: accidental);
          defaultSettings[notePosition] = {};
          if (notePosition.name == 'C8') break;
        }
      }
    }
  }

  Future<void> saveSettings(String settingsName, Map<NotePosition, Set<String>> settings) async {
    final prefs = await SharedPreferences.getInstance();
    String encodedSettings = json.encode(settings.map((k, v) => MapEntry(k.name, v.toList())));
    await prefs.setString(_settingsKeyPrefix + settingsName, encodedSettings);
  }

  Future<Map<NotePosition, Set<String>>> loadSettings(String settingsName) async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedSettings = prefs.getString(_settingsKeyPrefix + settingsName);
    if (encodedSettings != null) {
      Map<String, dynamic> decodedMap = json.decode(encodedSettings);
      return decodedMap.map((k, v) {
        var key = NotePosition.fromName(k)!;
        var value = v is List ? Set<String>.from(v) : <String>{v};
        return MapEntry(key, value);
      });
    } else {
      return Map<NotePosition, Set<String>>.from(defaultSettings);
    }
  }

  Future<void> deleteSettings(String settingsName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKeyPrefix + settingsName);
  }

  Future<List<String>> getAllSettingsNames() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    return keys.where((key) => key.startsWith(_settingsKeyPrefix))
        .map((key) => key.substring(_settingsKeyPrefix.length))
        .toList();
  }

  // Method to get the settings for a specific note
  Set<String>? getSettingsForNote(Map<NotePosition, Set<String>> settings, NotePosition note) {
    return settings[note];
  }

  // Method to get the notes for a specific setting
  Set<NotePosition> getNotesForSetting(Map<NotePosition, Set<String>> settings, String setting) {
    return settings.keys.where((k) => settings[k]!.contains(setting)).toSet();
  }

  // Method to set the settings for a specific note and remove it from other notes
  void setSettingsForNote(Map<NotePosition, Set<String>> settings, NotePosition note, String setting) {
    settings.putIfAbsent(note, () => <String>{}).add(setting);
  }

  // Method to reset settings to default
  void resetSettings(Map<NotePosition, Set<String>> settings) {
    settings.clear();
    settings.addAll(defaultSettings);
  }

  // Method to delete all settings for a specific note
  void deleteAllSettingsForNote(Map<NotePosition, Set<String>> settings, NotePosition note) {
    settings.remove(note);
  }

  // Method to delete a specific setting of a note
  void deleteSpecificSettingOfNote(Map<NotePosition, Set<String>> settings, NotePosition note, String setting) {
    if (settings.containsKey(note)) {
      settings[note]!.remove(setting);
      if (settings[note]!.isEmpty) {
        settings.remove(note);
      }
    }
  }
}
