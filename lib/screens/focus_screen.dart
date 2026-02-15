import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../widgets/small_clock.dart';
import '../services/sound_settings.dart';

enum Phase { focus, breakTime }

class FocusScreen extends StatefulWidget {
  final int focusMinutes;
  final int breakMinutes;

  const FocusScreen({
    super.key,
    required this.focusMinutes,
    required this.breakMinutes,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {

  final AudioPlayer player = AudioPlayer();

  Timer? timer;

  late int halfFocusSeconds;
  late int totalSeconds;

  int remainingSeconds = 0;

  Phase phase = Phase.focus;

  bool secondHalf = false;
  bool running = true;

  bool manualBreakActive = false;

  @override
  void initState() {
    super.initState();

    halfFocusSeconds = (widget.focusMinutes * 60 ~/ 2);

    startPhase(Phase.focus, halfFocusSeconds);
  }

  void startPhase(Phase newPhase, int seconds) {

    timer?.cancel();

    setState(() {
      phase = newPhase;
      totalSeconds = seconds;
      remainingSeconds = seconds;
      running = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (_) {

      if (!running) return;

      if (remainingSeconds <= 0) {
        onPhaseEnd();
      }
      else {
        setState(() => remainingSeconds--);
      }

    });
  }

  Future<void> onPhaseEnd() async {

    timer?.cancel();

    if (manualBreakActive) {

      manualBreakActive = false;

      final sound = await SoundSettings.getSound(
          SoundSettings.breakEnd,
          "break_end.mp3"
      );

      await player.play(AssetSource(sound));

      startPhase(Phase.focus, remainingSeconds);

      return;
    }

    if (phase == Phase.focus && !secondHalf) {

      secondHalf = true;

      final sound = await SoundSettings.getSound(
          SoundSettings.focusEnd,
          "focus_end.mp3"
      );

      await player.play(AssetSource(sound));

      startPhase(Phase.breakTime, widget.breakMinutes * 60);

    }
    else if (phase == Phase.breakTime) {

      final sound = await SoundSettings.getSound(
          SoundSettings.breakEnd,
          "break_end.mp3"
      );

      await player.play(AssetSource(sound));

      startPhase(Phase.focus, halfFocusSeconds);
    }
    else {

      final sound = await SoundSettings.getSound(
          SoundSettings.cycleComplete,
          "cycle_complete.mp3"
      );

      await player.play(AssetSource(sound));

      Navigator.pop(context);
    }
  }

  void startManualBreak(int seconds) {

    timer?.cancel();

    manualBreakActive = true;

    startPhase(Phase.breakTime, seconds);
  }

  String format(int s) {

    final m = s ~/ 60;
    final sec = s % 60;

    return "${m.toString().padLeft(2,'0')}:${sec.toString().padLeft(2,'0')}";
  }

  Widget breakChip(int min) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text("$min min"),
        selected: false,
        onSelected: (_) {

          Navigator.pop(context);

          startManualBreak(min * 60);
        },
      ),
    );
  }

  void showBreakSelector() {

    running = false;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Take a break"),
        content: Wrap(
          children: [
            breakChip(1),
            breakChip(3),
            breakChip(5),
            breakChip(10),
            breakChip(15),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double progress =
    totalSeconds == 0 ? 0 : remainingSeconds / totalSeconds;

    return Scaffold(

      backgroundColor: Colors.black,

      body: Row(

        children: [

          Expanded(
            flex: 3,

            child: Center(

              child: Stack(

                alignment: Alignment.center,

                children: [

                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      color: phase == Phase.focus
                          ? Colors.green
                          : Colors.blue,
                      backgroundColor: Colors.white12,
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Text(
                        phase == Phase.focus
                            ? "FOCUS"
                            : "BREAK",
                        style: const TextStyle(fontSize: 28),
                      ),

                      Text(
                        format(remainingSeconds),
                        style: const TextStyle(fontSize: 72),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: () =>
                      setState(() => running = !running),
                  child: Text(running ? "PAUSE" : "RESUME"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: showBreakSelector,
                  child: const Text("BREAK"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("HOME"),
                ),

                const SizedBox(height: 20),

                const SmallClock(),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
