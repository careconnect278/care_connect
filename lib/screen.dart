import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screen_state/screen_state.dart';

class ScreenStateEventEntry {
  ScreenStateEvent event;
  DateTime? time;

  ScreenStateEventEntry(this.event) {
    time = DateTime.now();
  }
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() =>  _MyAppState();
}



class _MyAppState extends State<MyApp> {
  final Screen _screen = Screen();
  StreamSubscription<ScreenStateEvent>? _subscription;
  bool started = false;
  List<ScreenStateEventEntry> _log = [];

  @override
  void initState() {
    super.initState();
    startListening();
  }
  Timer? timer;
int seconds=0;
 String formattedTime="00:00:00";
void startTimer() {
  seconds=0;
  formattedTime="00:00:00";
    timer = Timer.periodic(const Duration(seconds: 1), (tier) {
      setState(() {
        seconds++;
      formattedTime  = DateFormat('HH:mm:ss')
        .format(DateTime(0).add(Duration(seconds: seconds)));
      });

    });}
  /// Start listening to screen events
  void startListening() {
    try {
      _subscription = _screen.screenStateStream!.listen(_onData);
      setState(() => started = true);
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  void _onData(ScreenStateEvent event) {
    if(event==ScreenStateEvent.SCREEN_OFF){
      startTimer();
 setState(() {
      _log.add(ScreenStateEventEntry(event));
    });
    }else if(event==ScreenStateEvent.SCREEN_UNLOCKED){
      print('unloacked');
timer?.cancel();
    }
   
  }
  /// Stop listening to screen events
  void stopListening() {
    _subscription?.cancel();
    setState(() => started = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Screen State Example'),
        ),
        body: Center(
            child: Text(formattedTime)),
        floatingActionButton: FloatingActionButton(
          onPressed: started ? stopListening : startListening,
          tooltip: 'Start/Stop Listening',
          child: started ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}