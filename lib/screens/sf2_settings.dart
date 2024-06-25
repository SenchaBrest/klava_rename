import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsWidget extends StatefulWidget {
  final Function(List<dynamic>) onSave;
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
  List<dynamic> selectedOptions = [0, 0, 0, 0];

  final List<List<dynamic>> optionsData = [
    [0, 1, 2, 3, 4], // Data for first picker
    ['A', 'B', 'C', 'D'], // Data for second picker
    [10.0, 20.0, 30.0, 40.0], // Data for third picker
    ['One', 'Two', 'Three'] // Data for fourth picker
  ];

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
                children: List.generate(optionsData.length, (index) {
                  return Expanded(
                    child: CustomPicker(
                      initialValue: selectedOptions[index],
                      data: optionsData[index],
                      onSelectedItemChanged: (value) {
                        setState(() {
                          selectedOptions[index] = value;
                        });
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton.filled(
                    onPressed: () {
                      widget.onSave(selectedOptions);
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
}

class CustomPicker extends StatelessWidget {
  final dynamic initialValue;
  final List<dynamic> data;
  final ValueChanged<dynamic> onSelectedItemChanged;

  CustomPicker({
    required this.initialValue,
    required this.data,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
