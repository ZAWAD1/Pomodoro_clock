import 'package:flutter/material.dart';
import '../screens/focus_screen.dart';

//// ================= SETTINGS =================

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() =>
      _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {

  int selectedFocus = 30;
  int selectedBreak = 5;

  bool breakManuallyEdited = false;

  int clamp(int v) => v.clamp(1, 720);

  int suggestedBreak(int focus) {
    final b = (focus * 0.1).round();
    return b < 2 ? 2 : b;
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      scrollable: false,

      backgroundColor: Colors.black,

      title: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [

          const Text(
            "Focus period",
            style: TextStyle(
                fontFamily:
                'SFPRODISPLAYBOLD',
                fontSize: 24),
          ),

          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.pop(context),
          )

        ],
      ),

      content: Padding(

        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom,
        ),

        child: ConstrainedBox(

          constraints:
          const BoxConstraints(
              maxHeight: 160),

          child: SingleChildScrollView(

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: [

                const Text("Focus (min)",
                    style: TextStyle(
                        fontSize: 16)),

                const SizedBox(height: 8),

                _optionRow(
                  [15, 30, 60, 90, 120, 180],
                  selectedFocus,
                      (val) {

                    setState(() {

                      selectedFocus = val;

                      if (!breakManuallyEdited) {

                        selectedBreak =
                            suggestedBreak(val);

                      }

                    });

                  },
                ),

                const SizedBox(height: 20),

                const Text("Break (min)",
                    style: TextStyle(
                        fontSize: 16)),

                const SizedBox(height: 8),

                _optionRow(
                  [2, 5, 10, 15, 20, 30],
                  selectedBreak,
                      (val) {

                    setState(() {

                      selectedBreak = val;

                      breakManuallyEdited = true;

                    });

                  },
                ),

              ],

            ),

          ),

        ),

      ),

      actions: [

        SingleChildScrollView(

          scrollDirection: Axis.horizontal,

          child: ElevatedButton(

            onPressed: () {

              Navigator.pop(context);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FocusScreen(
                    focusMinutes:
                    selectedFocus,
                    breakMinutes:
                    selectedBreak,
                  ),
                ),
              );

            },

            child: const Text(
              "START",
              style: TextStyle(
                  fontFamily:
                  'SFPRODISPLAYBOLD',
                  fontSize: 16),
            ),

          ),

        )

      ],

    );

  }

  Widget _optionRow(
      List<int> options,
      int selected,
      Function(int) onTap) {

    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,

      child: Row(

        mainAxisSize:
        MainAxisSize.min,

        children: options
            .map(
              (option) => Padding(
            padding:
            const EdgeInsets.symmetric(
                horizontal: 4),

            child: ChoiceChip(
              label: Text(
                  option.toString()),

              selected:
              option == selected,

              onSelected: (_) =>
                  onTap(option),

            ),

          ),
        )
            .toList(),

      ),

    );

  }

}