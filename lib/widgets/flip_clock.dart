import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//// ================= CLOCK =================

class FlipClock extends StatelessWidget {

  const FlipClock({super.key});

  @override
  Widget build(BuildContext context) {

    final now = DateTime.now();

    return Column(

      children: [

        Text(DateFormat('dd/MM/yy')
            .format(now)),

        Text(
          DateFormat('hh:mm a')
              .format(now),
          style: const TextStyle(
              fontSize: 100),
        ),

        Text(DateFormat('EEEE')
            .format(now)),

      ],

    );

  }

}