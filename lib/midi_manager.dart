import 'package:flutter_midi_pro/flutter_midi_pro.dart';
import 'package:flutter/material.dart';

class MidiManager {
  final MidiPro midiPro = MidiPro();
  final ValueNotifier<Map<int, String>> loadedSoundfonts = ValueNotifier<Map<int, String>>({});
  final ValueNotifier<int?> selectedSfId = ValueNotifier<int?>(null);
  final ValueNotifier<int> instrumentIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> bankIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> channelIndex = ValueNotifier<int>(0);
  final ValueNotifier<int> volume = ValueNotifier<int>(127);

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
}
