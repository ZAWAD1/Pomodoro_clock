import 'package:flutter/material.dart';
import 'focus_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  int focus = 60;
  int brk = 6;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,

      title: const Text("Settings"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text("Focus"),

          Slider(
            value: focus.toDouble(),
            min: 1,
            max: 180,
            divisions: 179,
            label: "$focus",
            onChanged: (v) => setState(() => focus = v.toInt()),
          ),

          const Text("Break"),

          Slider(
            value: brk.toDouble(),
            min: 1,
            max: 60,
            divisions: 59,
            label: "$brk",
            onChanged: (v) => setState(() => brk = v.toInt()),
          ),
        ],
      ),

      actions: [

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FocusScreen(
                  focusMinutes: focus,
                  breakMinutes: brk,
                ),
              ),
            );
          },
          child: const Text("START"),
        )
      ],
    );
  }
}
