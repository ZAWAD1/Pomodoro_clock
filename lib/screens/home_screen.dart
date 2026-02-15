import 'package:flutter/material.dart';
import '../widgets/flip_clock.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const FlipClock(),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const SettingsScreen(),
                );
              },
              child: const Text("START FOCUS"),
            ),
          ],
        ),
      ),
    );
  }
}
