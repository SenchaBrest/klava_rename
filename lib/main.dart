import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_manager.dart';
import 'piano-lib/piano.dart';
import 'screens/sf2_settings.dart';
import 'package:flutter_midi_pro/flutter_midi_pro.dart';

void main() {
  runApp(KlavaRename());
}

class KlavaRename extends StatefulWidget {
  const KlavaRename({super.key});

  @override
  _KlavaRenameState createState() => _KlavaRenameState();
}

class _KlavaRenameState extends State<KlavaRename> {
  final MidiPro midiPro = MidiPro();
  final ValueNotifier<Map<int, String>> loadedSoundfonts = ValueNotifier<Map<int, String>>({});
  final ValueNotifier<int?> selectedSfId = ValueNotifier<int?>(null);
  final instrumentIndex = ValueNotifier<int>(0);
  final bankIndex = ValueNotifier<int>(0);
  final channelIndex = ValueNotifier<int>(0);
  final volume = ValueNotifier<int>(127);
  Map<NotePosition, String> settings = {};
  SettingsManager settingsManager = SettingsManager();
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
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      pressedKey = event.physicalKey.debugName ?? '';
      if (pressedKey == 'Audio Volume Up' || pressedKey == 'Audio Volume Down') {
        return false;
      }
      if (isBlocking) {
        setState(() {
          isBlocking = false;
          settingsManager.setSettingForNote(settings, tappedNote, pressedKey);
          saveSettings();
        });
      } else {
        playNoteFromSettings(pressedKey);
      }
    }
    return true;
  }

  void loadSoundFont() async {
    int sfId = await loadSoundfont('assets/sf2/Super_Nintendo_Unofficial_update.sf2', 0, 0);
    await selectInstrument(sfId: sfId, program: 0, channel: 0, bank: 0);
  }

  Future<int> loadSoundfont(String path, int bank, int program) async {
    if (loadedSoundfonts.value.containsValue(path)) {
      return loadedSoundfonts.value.entries.firstWhere((element) => element.value == path).key;
    }
    final int sfId = await midiPro.loadSoundfont(path: path, bank: bank, program: program);
    loadedSoundfonts.value = {sfId: path, ...loadedSoundfonts.value};
    return sfId;
  }

  Future<void> selectInstrument({
    required int sfId,
    required int program,
    int channel = 0,
    int bank = 0,
  }) async {
    int? sfIdValue = sfId;
    if (!loadedSoundfonts.value.containsKey(sfId)) {
      sfIdValue = loadedSoundfonts.value.keys.first;
    } else {
      selectedSfId.value = sfId;
    }
    await midiPro.selectInstrument(sfId: sfIdValue, channel: channel, bank: bank, program: program);
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

  void playNoteFromSettings(String key) {
    NotePosition? position = settingsManager.getNoteForSetting(settings, key);
    if (position != null) {
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

      playNote(
        key: midiNumber,
        velocity: volume.value,
        channel: channelIndex.value,
        sfId: selectedSfId.value!,
      );
    }
  }

  Future<void> playNote({
    required int key,
    required int velocity,
    int channel = 0,
    int sfId = 1,
  }) async {
    await midiPro.playNote(
      channel: channel,
      key: key,
      velocity: velocity,
      sfId: sfId,
    );
  }

  Future<void> stopNote({
    required int key,
    int channel = 0,
    int sfId = 1,
  }) async {
    await midiPro.stopNote(
      channel: channel,
      key: key,
      sfId: sfId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
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
            if (showSettings)
              SettingsWidget(
                onSave: (List<dynamic> option) {
                  setState(() {
                    showSettings = false;
                    print('Selected Options: $option');
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
}
