import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'piano-lib/src/note_position.dart';
import 'package:collection/collection.dart';

class SettingsManager {
  static const String _settingsKey = 'settings';
  final Map<NotePosition, String> defaultSettings = {};

  SettingsManager() {
    generateDefaultSettings();
  }

  void generateDefaultSettings() {
    List<Note> notes = Note.values;
    for (int octave = 0; octave <= 8; octave++) {
      for (Note note in notes) {
        for (Accidental accidental in note.accidentals) {
          NotePosition notePosition = NotePosition(note: note, octave: octave, accidental: accidental);
          defaultSettings[notePosition] = '';
          if (notePosition.name == 'C8') break;
        }
      }
    }
  }

  Future<void> saveSettings(Map<NotePosition, String> settings) async {
    final prefs = await SharedPreferences.getInstance();
    String encodedSettings = json.encode(settings.map((k, v) => MapEntry(k.name, v)));
    await prefs.setString(_settingsKey, encodedSettings);
  }

  Future<Map<NotePosition, String>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedSettings = prefs.getString(_settingsKey);
    if (encodedSettings != null) {
      Map<String, dynamic> decodedMap = json.decode(encodedSettings);
      return decodedMap.map((k, v) => MapEntry(NotePosition.fromName(k)!, v ?? ''));
    } else {
      return Map<NotePosition, String>.from(defaultSettings);
    }
  }

  // Method to get the setting for a specific note
  String? getSettingForNote(Map<NotePosition, String> settings, NotePosition note) {
    return settings[note];
  }

  // Method to get the note for a specific setting
  NotePosition? getNoteForSetting(Map<NotePosition, String> settings, String setting) {
    return settings.keys.firstWhereOrNull((k) => settings[k] == setting);
  }

  // Method to set the setting for a specific note and remove it from other notes
  void setSettingForNote(Map<NotePosition, String> settings, NotePosition note, String setting) {
    // Find the current note that has this setting and remove it
    NotePosition? currentNote = getNoteForSetting(settings, setting);
    if (currentNote != null) {
      settings[currentNote] = '';
    }

    // Assign the setting to the new note
    settings[note] = setting;
  }

  // Method to reset settings to default
  void resetSettings(Map<NotePosition, String> settings) {
    settings.clear();
    settings.addAll(defaultSettings);
  }
}
