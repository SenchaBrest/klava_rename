import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_manager.dart';
import 'piano-lib/piano.dart';
import 'widgets/note_settings_widget.dart';
import 'widgets/keyboard_settings_widget.dart';
import 'widgets/music_settings_widget.dart';
import 'keyboard_map.dart';

import 'package:flutter_sequencer/global_state.dart';
import 'package:flutter_sequencer/models/instrument.dart';
import 'package:flutter_sequencer/sequence.dart';
import 'package:flutter_sequencer/track.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KlavaRename());
}

class KlavaRename extends StatefulWidget {
  const KlavaRename({super.key});

  @override
  _KlavaRenameState createState() => _KlavaRenameState();
}

class _KlavaRenameState extends State<KlavaRename> with SingleTickerProviderStateMixin {
  Track? selectedTrack;
  List<Track> tracks = [];
  final sequence = Sequence(tempo: 120.0, endBeat: 80.0);

  Map<int, int> notesArePlaying = {};
  Map<String, Set<String>> settings = {};
  List<String> settingsNames = [];
  SettingsManager settingsManager = SettingsManager();
  late String currentSettingsName;

  bool isLoading = true;
  bool showNoteSettings = false;
  bool showSettings = false;
  bool showExtraButtons = false;
  bool showKeyboardSettings = false;
  bool showMusicSettings = false;
  late NotePosition tappedNote;
  Set<String> pressedKeys = {};
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    loadSoundFont();
    loadDefaultSettings();
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
    String pressedKey = getKeyLabel(event.physicalKey) ?? '';
    if (pressedKey == '') return false;

    if (event is KeyDownEvent) {
      if (showNoteSettings) {
        setState(() {
          showNoteSettings = false;
          settingsManager.setSettingsForNote(settings, tappedNote.name, pressedKey);
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
      setState(() {
        pressedKeys.remove(pressedKey);
      });
      stopNoteFromSettings(pressedKey);
    }
    return true;
  }

  void loadSoundFont() async {
    // Load sound font logic
  }

  void loadDefaultSettings() async {
    currentSettingsName = (await settingsManager.getDefaultSettingsName())!;
    settings = await settingsManager.loadSettings(currentSettingsName);

    setState(() {
      isLoading = false;
    });
  }

  void loadSettings() async {
    settings = await settingsManager.loadSettings(currentSettingsName);
    setState(() {
      isLoading = false;
    });
  }

  void saveSettings() async {
    await settingsManager.saveSettings(currentSettingsName, settings);
  }

  void playNoteFromSettings(String key) {
    Set<String> positions = settingsManager.getNotesForSetting(settings, key);
    List<int?> midiNumbers = positions.map((position) => NotePosition.fromName(position)?.pitch).toList();

    for (var midiNumber in midiNumbers) {
      if (midiNumber != null) {
        selectedTrack?.startNoteNow(noteNumber: midiNumber, velocity: 0.75);
      }
    }
  }

  void stopNoteFromSettings(String key) {
    Set<String> positions = settingsManager.getNotesForSetting(settings, key);
    List<int?> midiNumbers = positions.map((position) => NotePosition.fromName(position)?.pitch).toList();

    for (var midiNumber in midiNumbers) {
      if (midiNumber != null) {
        selectedTrack?.stopNoteNow(noteNumber: midiNumber);
      }
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
                  settingsManager.deleteAllSettingsForNote(settings, tappedNote.name);
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
            // if (showMusicSettings) ...[
            //   DoublePickerWidget(
            //     onSave: (String newCurrentSettingName) {
            //       // currentSettingsName = newCurrentSettingName;
            //       // loadSettings();
            //       setState(() {
            //         showMusicSettings = false;
            //       });
            //     },
            //     onCancel: () {
            //       setState(() {
            //         showMusicSettings = false;
            //       });
            //     },
            //   ),
            //
            // ],
            if (!showNoteSettings && !showKeyboardSettings && !showMusicSettings)
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
                            // CupertinoButton(
                            //   color: Colors.grey.withOpacity(0.5),
                            //   padding: const EdgeInsets.all(8),
                            //   child: const Icon(
                            //     Icons.music_note,
                            //     size: 30,
                            //     color: Colors.white,
                            //   ),
                            //   onPressed: () {
                            //     setState(() {
                            //       showExtraButtons = false;
                            //       showMusicSettings = true;
                            //     });
                            //   },
                            // ),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              color: Colors.grey.withOpacity(0.5),
                              padding: const EdgeInsets.all(8),
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
                      padding: const EdgeInsets.all(8),
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
