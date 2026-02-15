import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlipClock extends StatefulWidget {
  const FlipClock({super.key});

  @override
  State<FlipClock> createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> {
  late Timer timer;
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => setState(() => now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(DateFormat('dd/MM/yy').format(now),
            style: const TextStyle(color: Colors.white54)),

        Text(
          DateFormat('hh:mm a').format(now),
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(DateFormat('EEEE').format(now),
            style: const TextStyle(color: Colors.white54)),
      ],
    );
  }
}
