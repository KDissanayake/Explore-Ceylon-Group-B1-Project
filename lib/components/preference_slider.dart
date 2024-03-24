import 'package:flutter/material.dart';

class PreferenceSlider extends StatefulWidget {
  final List<String> allPreferences;
  final List<String> selectedPreferences;
  final Function(List<String>) onPreferencesChanged;
  final Map<String, Color> preferenceColors;

  const PreferenceSlider({
    Key? key,
    required this.allPreferences,
    required this.selectedPreferences,
    required this.onPreferencesChanged,
    required this.preferenceColors,
  }) : super(key: key);

  @override
  _PreferenceSliderState createState() => _PreferenceSliderState();
}

class _PreferenceSliderState extends State<PreferenceSlider> {
  late List<String> _allPreferences;

  @override
  void initState() {
    super.initState();
    _allPreferences = widget.allPreferences;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: (_allPreferences).map((preference) {
            return FilterChip(
              label: Text(
                preference,
                style: TextStyle(color: Colors.white),
              ),
              selected: (widget.selectedPreferences).contains(preference),
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    widget.selectedPreferences.add(preference);
                  } else {
                    widget.selectedPreferences.remove(preference);
                  }
                  widget.onPreferencesChanged(widget.selectedPreferences);
                });
              },
              selectedColor: widget.preferenceColors[preference] ?? Colors.grey,
              checkmarkColor: Color.fromARGB(255, 255, 255, 255),
              showCheckmark: true,
              backgroundColor: Color(0xFF456461),
              labelStyle: TextStyle(
                color: (widget.selectedPreferences).contains(preference)
                    ? const Color.fromARGB(0, 255, 255, 255)
                    : Colors.black,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
