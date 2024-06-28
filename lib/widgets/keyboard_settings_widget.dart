import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SinglePickerWidget extends StatefulWidget {
  final List<dynamic> initialData;
  final Function(List<dynamic>, dynamic) onSave;
  final VoidCallback onCancel;

  const SinglePickerWidget({
    super.key,
    required this.initialData,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _SinglePickerWidgetState createState() => _SinglePickerWidgetState();
}

class _SinglePickerWidgetState extends State<SinglePickerWidget> {
  List<dynamic> pickerData = [];
  dynamic selectedValue;
  TextEditingController textController = TextEditingController();
  bool showInputField = false;

  @override
  void initState() {
    super.initState();
    pickerData = List.from(widget.initialData);
    if (pickerData.isNotEmpty) {
      selectedValue = pickerData[0];
    }
  }

  void _addEntry(String newEntry) {
    setState(() {
      pickerData.add(newEntry);
      selectedValue = newEntry;
      showInputField = false; // Hide input field after adding entry
    });
  }

  void _removeEntry() {
    if (pickerData.isNotEmpty) {
      setState(() {
        pickerData.remove(selectedValue);
        if (pickerData.isNotEmpty) {
          selectedValue = pickerData[0];
        } else {
          selectedValue = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: showInputField
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
                  color: Colors.grey,
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
          : Row(
        children: [
          // Left side: Picker and buttons
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: CustomPicker(
                    initialValue: selectedValue,
                    data: pickerData,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.save, color: Colors.green),
                      onPressed: () {
                        widget.onSave(pickerData, selectedValue);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: widget.onCancel,
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_upload, color: Colors.grey),
                      onPressed: () {
                        // Import functionality
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.file_download, color: Colors.grey),
                      onPressed: () {
                        // Export functionality
                      },
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
                const SizedBox(height: 20), // Add space if needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPicker extends StatelessWidget {
  final dynamic initialValue;
  final List<dynamic> data;
  final ValueChanged<dynamic> onSelectedItemChanged;

  const CustomPicker({super.key,
    required this.initialValue,
    required this.data,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: CupertinoPicker(
        backgroundColor: Colors.black87,
        itemExtent: 30,
        scrollController: FixedExtentScrollController(initialItem: data.indexOf(initialValue)),
        children: data.map<Widget>((item) {
          return Center(
            child: Text(
              item.toString(),
              style: const TextStyle(color: Colors.white),
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
