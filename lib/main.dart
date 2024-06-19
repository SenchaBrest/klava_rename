import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_manager.dart';
import 'piano-lib/piano.dart';
import 'screens/sf2_settings.dart';
// import 'package:flutter_midi/flutter_midi.dart';

void main() {
  runApp(KlavaRename());
}

class KlavaRename extends StatefulWidget {
  const KlavaRename({super.key});

  @override
  _KlavaRenameState createState() => _KlavaRenameState();
}

class _KlavaRenameState extends State<KlavaRename> {
  // FlutterMidi flutterMidi = FlutterMidi();
  SettingsManager settingsManager = SettingsManager();
  Map<NotePosition, String> settings = {};
  bool isLoading = true;
  bool isBlocking = false;
  bool showSettings = false;
  late NotePosition tappedNote;
  String pressedKey = "";

  @override
  void initState() {
    super.initState();
    loadSoundFont();
    loadSettings();
  }

  void loadSoundFont() async {
    // ByteData byteData = await rootBundle.load('assets/sf2/Super_Nintendo_Unofficial_update.sf2');
    // flutterMidi.prepare(sf2: byteData, name: "Super_Nintendo_Unofficial_update.sf2");
  }

  void loadSettings() async {
    settings = await settingsManager.loadSettings();
    setState(() {
      isLoading = false;
    });
  }

  void saveSettings() async {
    await settingsManager.saveSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          pressedKey = event.logicalKey.debugName ?? '';
          if (isBlocking) {
            setState(() {
              isBlocking = false;
              settingsManager.setSettingForNote(settings, tappedNote, pressedKey);
              saveSettings();
            });
          } else {
            playNote(settingsManager.getNoteForSetting(settings, pressedKey));
            print(1);
          }
        }
      },
      child: CupertinoApp(
        title: 'Klava Rename',
        home: Scaffold(
          body: Stack(
            children: [
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : InteractivePiano(
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
                      isBlocking = true;
                    });
                  },
                ),
              ),
              if (isBlocking) ...[
                AbsorbPointer(
                  absorbing: true,
                  child: Opacity(
                    opacity: 0.6,
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                ),
                buildBlockingWidget(),
              ],
              Positioned(
                top: 40,
                right: 20,
                child: isBlocking
                    ? Container()
                    : CupertinoButton(
                  color: Colors.grey.withOpacity(0.5),
                  padding: EdgeInsets.all(8),
                  child: const Icon(
                    Icons.settings,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      showSettings = true;
                    });
                  },
                ),
              ),
              // Внутри метода build основного виджета
              // Внутри метода build основного виджета
              if (showSettings)
                SettingsWidget(
                  onSave: (int option1, int option2, int option3, int option4) {
                    setState(() {
                      showSettings = false;
                      print('Selected Option 1: $option1');
                      print('Selected Option 2: $option2');
                      print('Selected Option 3: $option3');
                    });
                  },
                  onCancel: () {
                    setState(() {
                      showSettings = false;
                    });
                  },
                ),


            ],

          ),
        ),
      ),
    );
  }

  Widget buildBlockingWidget() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                  children: [
                    const TextSpan(text: "You set up "),
                    TextSpan(
                      text: "${tappedNote.note.name}${tappedNote.octave}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Press any key to continue",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    child: CupertinoButton(
                      color: Colors.blueGrey,
                      padding: EdgeInsets.zero,
                      child: const Icon(
                        Icons.cancel,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isBlocking = false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 60,
                    child: CupertinoButton(
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      child: const Icon(
                        Icons.delete,
                        size: 30,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isBlocking = false;
                        });
                        settingsManager.setSettingForNote(settings, tappedNote, '');
                        saveSettings();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void playNote(NotePosition? position) {
    // if (position != null) {
    //   int midiNumber = position.octave * 12 + position.note.index + 21;
    //   flutterMidi.playMidiNote(midi: midiNumber);
    // }
  }
}
