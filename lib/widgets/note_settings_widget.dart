import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoteSettingsWidget extends StatefulWidget {
  final String text;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const NoteSettingsWidget({
    super.key,
    required this.text,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  _NoteSettingsWidgetState createState() => _NoteSettingsWidgetState();
}

class _NoteSettingsWidgetState extends State<NoteSettingsWidget> {
  @override
  Widget build(BuildContext context) {
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
                      text: widget.text,
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
                      onPressed: widget.onCancel,
                      child: const Icon(
                        Icons.cancel,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 60,
                    child: CupertinoButton(
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      onPressed: widget.onDelete,
                      child: const Icon(
                        Icons.delete,
                        size: 30,
                        color: Colors.white,
                      ),
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
