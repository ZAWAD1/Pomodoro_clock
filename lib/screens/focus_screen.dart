import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/phase.dart';

//// ================= FOCUS =================

class FocusScreen extends StatefulWidget {

  final int focusMinutes;
  final int breakMinutes;

  const FocusScreen({
    super.key,
    required this.focusMinutes,
    required this.breakMinutes,
  });

  @override
  State<FocusScreen> createState() =>
      _FocusScreenState();

}

class _FocusScreenState extends State<FocusScreen> {

  final AudioPlayer _player =
  AudioPlayer();

  Timer? _timer;

  late int halfFocus;
  late int totalSeconds;

  int remainingSeconds = 0;

  Phase phase = Phase.focus;

  bool secondHalf = false;
  bool running = true;

  @override
  void initState() {

    super.initState();

    // ADDED → prevent sleep
    WakelockPlus.enable();

    halfFocus =
        (widget.focusMinutes / 2)
            .round();

    startPhase(
        Phase.focus,
        halfFocus);

  }

  void startPhase(
      Phase p,
      int minutes) {

    _timer?.cancel();

    phase = p;

    totalSeconds =
        minutes * 60;

    remainingSeconds =
        totalSeconds;

    running = true;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {

        if (!running) return;

        if (remainingSeconds <= 1) {

          onPhaseEnd();

        } else {

          setState(() =>
          remainingSeconds--);

        }

      },
    );

  }

  Future<void> onPhaseEnd() async {

    _timer?.cancel();

    if (phase ==
        Phase.focus &&
        !secondHalf) {

      await _player.play(
          AssetSource(
              'focus_end.mp3'));

      secondHalf = true;

      startPhase(
          Phase.breakTime,
          widget.breakMinutes);

    } else if (phase ==
        Phase.breakTime) {

      await _player.play(
          AssetSource(
              'break_end.mp3'));

      startPhase(
          Phase.focus,
          halfFocus);

    } else {

      await _player.play(
          AssetSource(
              'cycle_complete.mp3'));

      if(mounted){
        Navigator.pop(context);
      }

    }

  }

  String timeText() {

    final m =
        remainingSeconds ~/ 60;

    final s =
        remainingSeconds % 60;

    return
      '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

  }

  @override
  void dispose() {

    // sleep enable.
    WakelockPlus.enable();

    _timer?.cancel();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: Row(

        children: [

          Expanded(

            flex: 3,

            child: Center(

              child: Stack(

                alignment:
                Alignment.center,

                children: [

                  SizedBox(

                    width: 300,
                    height: 300,

                    child:
                    CircularProgressIndicator(

                      value:
                      remainingSeconds /
                          totalSeconds,

                      strokeWidth: 15,

                      color:
                      phase == Phase.focus ? Colors.green : Colors.lightBlue,

                      backgroundColor:
                      Colors.white12,

                    ),

                  ),

                  Column(

                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                    children: [

                      Text(
                        phase ==
                            Phase.focus
                            ? "FOCUS"
                            : "BREAK",

                        style: const TextStyle(
                            fontFamily:
                            'SFPRODISPLAYBOLD',
                            fontSize: 28),

                      ),

                      const SizedBox(
                          height: 12),

                      Text(
                        timeText(),
                        style: const TextStyle(
                            fontFamily:
                            'SFPRODISPLAYBOLD',
                            fontSize: 72),
                      ),

                    ],

                  )

                ],

              ),

            ),

          ),

          Expanded(

            flex: 2,

            child: Column(

              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                ElevatedButton(

                  onPressed: () =>
                      setState(() =>
                      running =
                      !running),

                  child: Text(
                      running
                          ? "PAUSE"
                          : "RESUME"),

                ),

                const SizedBox(
                    height: 12),

                ElevatedButton(

                  onPressed: () =>
                      Navigator.pop(
                          context),

                  child:
                  const Text("HOME"),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}
