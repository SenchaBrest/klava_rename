import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../settings_manager.dart';

class SinglePickerWidget extends StatefulWidget {
  final Function(String) onSave;
  final VoidCallback onCancel;

  const SinglePickerWidget({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _SinglePickerWidgetState createState() => _SinglePickerWidgetState();
}

class _SinglePickerWidgetState extends State<SinglePickerWidget> {
  List<String> pickerData = [];
  dynamic selectedValue;
  TextEditingController textController = TextEditingController();
  bool showInputField = false;
  final SettingsManager settingsManager = SettingsManager();
  String? defaultSettingsName;
  Key customPickerKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    List<String> settingsNames = await settingsManager.getAllSettingsNames();
    String? defaultName = await settingsManager.getDefaultSettingsName();
    setState(() {
      pickerData = settingsNames;
      defaultSettingsName = defaultName;
      if (pickerData.isNotEmpty) {
        selectedValue = defaultName ?? pickerData[0];
      }
    });
  }

  Future<void> _addEntry(String newEntry) async {
    newEntry = await settingsManager.addDefaultSettings(newEntry);
    setState(() {

      pickerData.add(newEntry);
      selectedValue = newEntry;
      showInputField = false; // Hide input field after adding entry
    });
  }

  Future<void> _removeEntry() async {
    if (pickerData.isNotEmpty) {
      String entryToRemove = selectedValue;
      bool toRemove = await settingsManager.deleteSettings(entryToRemove);
      if (toRemove) {
        setState(() {
          pickerData.remove(entryToRemove);
          if (pickerData.isNotEmpty) {
            selectedValue = defaultSettingsName ?? pickerData[0];
          } else {
            selectedValue = null;
          }
          customPickerKey = UniqueKey(); // Update key to trigger rebuild of CustomPicker
        });
      }
    }
  }

  Future<void> _setDefaultSettings(String settingsName) async {
    await settingsManager.setDefaultSettings(settingsName);
    setState(() {
      defaultSettingsName = settingsName;
    });
  }

  Future<void> _showUploadDialog() async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Import'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Paste'),
              onPressed: () async {
                Navigator.of(context).pop();
                ClipboardData? clipboardData = await Clipboard.getData('text/plain');
                if (clipboardData != null && clipboardData.text != null) {
                  String importName = await settingsManager.importSettingsFromJsonString(clipboardData.text!);
                  setState(() {
                    pickerData.add(importName);
                    selectedValue = importName;
                  });

                }
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDownloadDialog() async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Export'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Copy'),
              onPressed: () async {
                Navigator.of(context).pop();
                String str = await settingsManager.exportSettingsToJsonString(selectedValue);
                Clipboard.setData(ClipboardData(text: str));
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: showInputField
            ? Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: textController,
                  placeholder: 'Enter new entry',
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.save, color: Colors.green),
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    _addEntry(textController.text);
                    textController.clear();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  setState(() {
                    showInputField = false;
                  });
                },
              ),
              const SizedBox(width: 10),
            ],
          ),
        )
            : Column(
          children: [
            Expanded(
              child: pickerData.isNotEmpty
                  ? CustomPicker(
                keyForPicker: customPickerKey, // Pass key to CustomPicker
                initialValue: selectedValue,
                data: pickerData,
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              )
                  : const Center(
                child: Text(
                  'No data available',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.save, color: Colors.green),
                  onPressed: () {
                    if (selectedValue != null) {
                      widget.onSave(selectedValue);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  onPressed: widget.onCancel,
                ),
                IconButton(
                  icon: const Icon(Icons.paste, color: Colors.grey),
                  onPressed: _showUploadDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.grey),
                  onPressed: _showDownloadDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      showInputField = true;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _removeEntry,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: selectedValue == defaultSettingsName,
                  onChanged: (bool? value) {
                    if (value == true) {
                      _setDefaultSettings(selectedValue);
                    }
                  },
                  checkColor: CupertinoColors.white,
                  activeColor: Colors.green,
                ),
                const Text(
                  'Set as default',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CustomPicker extends StatelessWidget {
  final Key keyForPicker;
  final dynamic initialValue;
  final List<dynamic> data;
  final ValueChanged<dynamic> onSelectedItemChanged;

  const CustomPicker({required this.keyForPicker, required this.initialValue, required this.data, required this.onSelectedItemChanged});

  @override
  Widget build(BuildContext context) {
    final scrollController = FixedExtentScrollController(initialItem: data.indexOf(initialValue));

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: CupertinoPicker(
        key: keyForPicker, // Use the provided key
        backgroundColor: CupertinoColors.black,
        itemExtent: 30,
        scrollController: scrollController,
        children: data.map<Widget>((item) {
          return Center(
            child: Text(
              item.toString(),
              style: const TextStyle(color: CupertinoColors.white),
            ),
          );
        }).toList(),
        onSelectedItemChanged: (index) {
          onSelectedItemChanged(data[index]);
        },
      ),
    );
  }
}
