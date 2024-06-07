import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'piano-lib/piano.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: 'Piano Demo',
        home: Center(
          child: InteractivePiano(
            // highlightedNotes: [
            //   NotePosition(note: Note.C, octave: 1)
            // ],
            naturalColor: Colors.white,
            accidentalColor: Colors.black,
            keyWidth: 60,
            noteRange: NoteRange(
                from: NotePosition(note: Note.A, octave: 0),
                to: NotePosition(note: Note.C, octave: 8)
            ),
            onNotePositionTapped: (position) {
              // Use an audio library like flutter_midi to play the sound

            },
          ),
        ));
  }
}