import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SettingsWidget extends StatefulWidget {
  final Function(int, int, int, int) onSave;
  final VoidCallback onCancel;

  const SettingsWidget({
    Key? key,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int selectedOption1 = 0;
  int selectedOption2 = 0;
  int selectedOption3 = 0;
  int selectedOption4 = 0;
  String? selectedFile;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Settings",
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildPicker(1),
                  ),
                  Expanded(
                    child: _buildPicker(2),
                  ),
                  Expanded(
                    child: _buildPicker(3),
                  ),
                  Expanded(
                    child: _buildPicker(4),
                  ),
                  CupertinoButton(
                    color: Colors.blue,
                    child: const Text(
                      "Select File",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    onPressed: _pickFile,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton.filled(
                    onPressed: () {
                      widget.onSave(selectedOption1, selectedOption2, selectedOption3, selectedOption4);
                    },
                    child: const Text('Save Settings'),
                  ),
                  const SizedBox(width: 10),
                  CupertinoButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker(int option) {
    List<Widget> items = List<Widget>.generate(15, (int index) {
      return Center(child: Text('Option $index', style: const TextStyle(color: Colors.white)));
    });

    if (option == 4 && selectedFile != null) {
      items.add(Center(child: Text('Selected File: $selectedFile', style: const TextStyle(color: Colors.white))));
    }

    return Container(
      height: 200,
      child: CupertinoPicker(
        backgroundColor: Colors.black87,
        itemExtent: 30,
        scrollController: FixedExtentScrollController(
          initialItem: option == 1
              ? selectedOption1
              : option == 2
              ? selectedOption2
              : option == 3
              ? selectedOption3
              : selectedOption4,
        ),
        children: items,
        onSelectedItemChanged: (int value) {
          setState(() {
            if (option == 1) {
              selectedOption1 = value;
            } else if (option == 2) {
              selectedOption2 = value;
            } else if (option == 3) {
              selectedOption3 = value;
            } else {
              selectedOption4 = value;
            }
          });
        },
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFile = result.files.single.name;
        selectedOption4 = 0;  // Reset selected option for the fourth picker
      });
    }
  }
}
