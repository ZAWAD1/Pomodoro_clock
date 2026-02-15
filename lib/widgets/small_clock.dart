import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SmallClock extends StatefulWidget {
  const SmallClock({super.key});

  @override
  State<SmallClock> createState() => _SmallClockState();
}

class _SmallClockState extends State<SmallClock> {
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
    return Text(
      DateFormat('hh:mm:ss a').format(now),
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white54,
      ),
    );
  }
}
