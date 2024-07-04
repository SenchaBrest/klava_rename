import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_manager.dart';
import 'piano-lib/piano.dart';
import 'screens/sf2_settings.dart';
import 'widgets/note_settings_widget.dart';
import 'widgets/keyboard_settings_widget.dart';

import 'package:flutter_sequencer/global_state.dart';
import 'package:flutter_sequencer/models/sfz.dart';
import 'package:flutter_sequencer/models/instrument.dart';
import 'package:flutter_sequencer/sequence.dart';
import 'package:flutter_sequencer/track.dart';

void main() {
  runApp(KlavaRename());
}

class KlavaRename extends StatefulWidget {
  const KlavaRename({super.key});

  @override
  _KlavaRenameState createState() => _KlavaRenameState();
}

class _KlavaRenameState extends State<KlavaRename> with SingleTickerProviderStateMixin {
  Track? selectedTrack;
  List<Track> tracks = [];
  final sequence = Sequence(tempo: 120.0, endBeat: 8.0);

  Map<int, int> notesArePlaying = {};
  Map<NotePosition, Set<String>> settings = {};
  List<String> settingsNames = [];
  SettingsManager settingsManager = SettingsManager();
  String defaultSettingsName = 'default';
  String currentSettingsName = 'default';

  bool isLoading = true;
  bool showNoteSettings = false;
  bool showSettings = false;
  bool showExtraButtons = false;
  bool showKeyboardSettings = false;
  late NotePosition tappedNote;
  Set<String> pressedKeys = {};
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    loadSoundFont();
    loadSettings();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    GlobalState().setKeepEngineRunning(true);

    final instruments = [
      Sf2Instrument(path: "assets/sf2/Yamaha_XG_Sound_Set.sf2", isAsset: true),
    ];

    sequence.createTracks(instruments).then((tracks) {
      this.tracks = tracks;
      setState(() {
        selectedTrack = tracks[0];
      });
    });
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _animationController.dispose();
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      String pressedKey = event.physicalKey.debugName ?? '';
      if (pressedKey == 'Audio Volume Up' || pressedKey == 'Audio Volume Down') {
        return false;
      }
      if (showNoteSettings) {
        setState(() {
          showNoteSettings = false;
          settingsManager.setSettingsForNote(settings, tappedNote, pressedKey);
          saveSettings();
        });
      } else {
        setState(() {
          pressedKeys.add(pressedKey);
        });
        playNoteFromSettings(pressedKey);
      }
    }

    if (event is KeyUpEvent) {
      String releasedKey = event.physicalKey.debugName ?? '';
      setState(() {
        pressedKeys.remove(releasedKey);
      });
      stopNoteFromSettings(releasedKey);
    }
    return true;
  }

  void loadSoundFont() async {
    // Load sound font logic
  }

  void loadSettings() async {
    settings = await settingsManager.loadSettings(currentSettingsName);
    settingsNames = await settingsManager.getAllSettingsNames();
    setState(() {
      isLoading = false;
    });
  }

  void saveSettings() async {
    await settingsManager.saveSettings(currentSettingsName, settings);
  }

  void playNoteFromSettings(String key) {
    Set<NotePosition>? positions = settingsManager.getNotesForSetting(settings, key);
    for (var position in positions) {
      Map<String, int> noteValues = {
        'C': 0, 'C♯': 1,
        'D': 2, 'D♯': 3,
        'E': 4,
        'F': 5, 'F♯': 6,
        'G': 7, 'G♯': 8,
        'A': 9, 'A♯': 10,
        'B': 11,
      };
      int midiNumber = 12 * (position.octave + 1) + noteValues["${position.note.name}${position.accidental.symbol}"]!;
      selectedTrack?.startNoteNow(noteNumber: midiNumber, velocity: 0.75);
    }
  }

  void stopNoteFromSettings(String key) {
    Set<NotePosition>? positions = settingsManager.getNotesForSetting(settings, key);
    for (var position in positions) {
      Map<String, int> noteValues = {
        'C': 0, 'C♯': 1,
        'D': 2, 'D♯': 3,
        'E': 4,
        'F': 5, 'F♯': 6,
        'G': 7, 'G♯': 8,
        'A': 9, 'A♯': 10,
        'B': 11,
      };
      int midiNumber = 12 * (position.octave + 1) + noteValues["${position.note.name}${position.accidental.symbol}"]!;
      selectedTrack?.stopNoteNow(noteNumber: midiNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Klava Rename',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : AbsorbPointer(
                absorbing: showExtraButtons || showNoteSettings,
                child: InteractivePiano(
                  settings: settings,
                  naturalColor: Colors.white,
                  accidentalColor: Colors.black,
                  keyWidth: 60,
                  noteRange: NoteRange(
                    from: NotePosition(note: Note.A, octave: 0),
                    to: NotePosition(note: Note.C, octave: 8),
                  ),
                  onNotePositionTapped: (position) {
                    setState(() {
                      tappedNote = position;
                      showNoteSettings = true;
                    });
                  },
                ),
              ),
            ),
            if (showNoteSettings) ...[
              NoteSettingsWidget(
                text: "${tappedNote.note.name}${tappedNote.octave}",
                onCancel: () {
                  setState(() {
                    showNoteSettings = false;
                  });
                },
                onDelete: () {
                  setState(() {
                    showNoteSettings = false;
                  });
                  settingsManager.deleteAllSettingsForNote(settings, tappedNote);
                  saveSettings();
                },
              ),
            ],
            if (showKeyboardSettings) ...[
              SinglePickerWidget(
                onSave: (String newCurrentSettingName) {
                  currentSettingsName = newCurrentSettingName;
                  loadSettings();
                  setState(() {
                    showKeyboardSettings = false;
                  });
                },
                onCancel: () {
                  setState(() {
                    showKeyboardSettings = false;
                  });
                },
              ),
            ],
            if (!showNoteSettings && !showKeyboardSettings)
              Positioned(
                top: 40,
                right: 20,
                child: Row(
                  children: [
                    if (showExtraButtons)
                      SlideTransition(
                        position: _offsetAnimation,
                        child: Row(
                          children: [
                            CupertinoButton(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(8),
                              child: const Icon(
                                Icons.music_note,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // Your volume up action
                              },
                            ),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              color: Colors.grey.withOpacity(0.5),
                              padding: EdgeInsets.all(8),
                              child: const Icon(
                                Icons.keyboard,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  showExtraButtons = false;
                                  showKeyboardSettings = true;
                                });
                              },
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    CupertinoButton(
                      color: Colors.grey.withOpacity(0.5),
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        !showExtraButtons ? Icons.settings : Icons.keyboard_double_arrow_right,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          showExtraButtons = !showExtraButtons;
                          if (showExtraButtons) {
                            _animationController.forward();
                          } else {
                            _animationController.reverse();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
