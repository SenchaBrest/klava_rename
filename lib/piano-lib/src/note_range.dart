import 'package:collection/collection.dart';

import 'note_position.dart';

class NoteRange {
  final NotePosition firstPosition;
  final NotePosition lastPosition;
  final List<NotePosition> allPositions;
  final List<NotePosition> naturalPositions;

  NoteRange({
    required NotePosition from,
    required NotePosition to,
    Accidental accidentals = Accidental.Sharp,
  })  : firstPosition = from,
        lastPosition = to,
        allPositions = _positions(from, to, accidentals: accidentals),
        naturalPositions = _positions(from, to, accidentals: Accidental.None);

  bool contains(NotePosition notePosition) =>
      allPositions.firstWhereOrNull((_) =>
          _ == notePosition || _.alternativeAccidental == notePosition) !=
      null;

  static List<NotePosition> _positions(NotePosition from, NotePosition to,
      {required Accidental accidentals}) {
    final List<NotePosition> positions = [];

    final fromFirstOctave = Note.values.skip(Note.values.indexOf(from.note));
    positions.addAll(
        fromFirstOctave.map((_) => NotePosition(note: _, octave: from.octave)));

    if (to.octave > from.octave + 1) {
      for (int octave = from.octave + 1; octave < to.octave; octave++) {
        positions.addAll(
            Note.values.map((_) => NotePosition(note: _, octave: octave)));
      }
    }

    final toLastOctave =
        Note.values.sublist(0, Note.values.indexOf(to.note) + 1);
    positions.addAll(
        toLastOctave.map((_) => NotePosition(note: _, octave: to.octave)));

    if (accidentals != Accidental.None) {
      int length = positions.length;
      int index = 0;

      // Until the note before the final note (since we can't finish on an accidental)
      while (index < length - 1) {
        switch (positions[index].note) {
          case Note.C:
          case Note.D:
          case Note.F:
          case Note.G:
          case Note.A:
            var accidental = NotePosition(
                note: positions[index].note,
                octave: positions[index].octave,
                accidental: Accidental.Sharp);

            if (accidentals == Accidental.Flat) {
              accidental = accidental.alternativeAccidental ?? accidental;
            }

            positions.insert(index + 1, accidental);
            index += 1; // skip over inserted note
            length += 1; // one note was added
            break;
          default:
            break;
        }
        index += 1;
      }
    }

    return positions;
  }
}
