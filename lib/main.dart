import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const PomodoroApp());
}

enum Phase { focus, breakTime }

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

//// ================= HOME =================

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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const SettingsDialog(),
              ),
              child: const Text("START FOCUS", style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD', fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}

//// ================= SETTINGS =================

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int selectedFocus = 60;
  int selectedBreak = 6;
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Focus period", style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD', fontSize: 24)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      content: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 160),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Focus (min)", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                _optionRow([1, 30, 60, 90, 120, 180], selectedFocus, (val) {
                  setState(() {
                    selectedFocus = val;
                    if (!breakManuallyEdited) {
                      selectedBreak = suggestedBreak(val);
                    }
                  });
                }),
                const SizedBox(height: 20),
                const Text("Break (min)", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                _optionRow([1, 5, 10, 15, 20, 30], selectedBreak, (val) {
                  setState(() {
                    selectedBreak = val;
                    breakManuallyEdited = true;
                  });
                }),
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
                    focusMinutes: selectedFocus,
                    breakMinutes: selectedBreak,
                  ),
                ),
              );
            },
            child: const Text("START", style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD', fontSize: 16)),
          ),
        )
      ],
    );
  }

  Widget _optionRow(List<int> options, int selected, Function(int) onTap) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(option.toString()),
            selected: option == selected,
            onSelected: (_) => onTap(option),
          ),
        )).toList(),
      ),
    );
  }
}

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
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final AudioPlayer _player = AudioPlayer();
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
    halfFocus = (widget.focusMinutes / 2).round();
    startPhase(Phase.focus, halfFocus);
  }

  void startPhase(Phase p, int minutes) {
    _timer?.cancel();
    phase = p;
    totalSeconds = minutes * 60;
    remainingSeconds = totalSeconds;
    running = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!running) return;
      if (remainingSeconds <= 1) {
        onPhaseEnd();
      } else {
        setState(() => remainingSeconds--);
      }
    });
  }

  Future<void> onPhaseEnd() async {
    _timer?.cancel();

    if (phase == Phase.focus && !secondHalf) {
      await _player.play(AssetSource('focus_end.mp3'));
      secondHalf = true;
      startPhase(Phase.breakTime, widget.breakMinutes);
    } else if (phase == Phase.breakTime) {
      await _player.play(AssetSource('break_end.mp3'));
      startPhase(Phase.focus, halfFocus);
    } else {
      await _player.play(AssetSource('cycle_complete.mp3'));
      showSuccess();
    }
  }

  void showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Session Complete 🎉",style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD', fontSize: 26)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            )
          ],
        ),
        content: const Text("You did it!  Good work,  KEEP UP.",
            style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD', fontSize: 18)
        ),
      ),
    );
  }

  String timeText() {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      value: remainingSeconds / totalSeconds,
                      strokeWidth: 10,
                      color: Colors.green,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        phase == Phase.focus ? "FOCUS" : "BREAK",
                        style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        timeText(),
                          style: TextStyle(
                              fontFamily: 'SFPRODISPLAYBOLD',
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => running = !running),
                  child: Text(running ? "PAUSE" : "RESUME" ,style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD', fontSize: 18)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("HOME", style: TextStyle(fontFamily: 'SFPRODISPLAYBOLD', fontSize: 18)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//// ================= CLOCK =================

class FlipClock extends StatelessWidget {
  const FlipClock({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        Text(
          DateFormat('dd/MM/yy').format(now),
          style: const TextStyle(color: Colors.white54),
        ),
        Text(
          DateFormat('hh:mm a').format(now),
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          DateFormat('EEEE').format(now),
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }
}
