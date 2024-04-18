import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

/// The type of screen state events coming from Android.
// ignore: constant_identifier_names
enum ScreenStateEvent { 
  /// Represents the event when the screen is unlocked by the user.
  SCREEN_UNLOCKED, 
  
  /// Represents the event when the screen is turned on.
  SCREEN_ON, 
  
  /// Represents the event when the screen is turned off.
  SCREEN_OFF 
}

/// Custom Exception for the `screen_state` plugin, used whenever the plugin
/// is used on platforms other than Android
class ScreenStateException implements Exception {
  String _cause;

  ScreenStateException(this._cause);

  @override
  String toString() => '$runtimeType - $_cause';
}

/// Screen representation as object which holds the stream for [ScreenStateEvent]s.
class Screen {
  static Screen? _singleton;
  final EventChannel _eventChannel = const EventChannel('screenStateEvents');
  Stream<ScreenStateEvent>? _screenStateStream;

  /// Constructs a singleton instance of [Screen].
  ///
  /// [Screen] is designed to work as a singleton.
  factory Screen() => _singleton ??= Screen._();

  Screen._();

  /// Stream of [ScreenStateEvent]s.
  /// Each event is streamed as it occurs on the phone.
  /// Only Android [ScreenStateEvent] are streamed.
  Stream<ScreenStateEvent>? get screenStateStream {
    // Check if the platform is Android
    if (Platform.isAndroid) {
      // Initialize the screen state stream if not initialized yet
      _screenStateStream ??= _eventChannel
          .receiveBroadcastStream()
          // Map raw event strings to ScreenStateEvent enum values
          .map((event) => _parseScreenStateEvent(event));
      return _screenStateStream;
    }
    // Throw an exception if the platform is not Android
    throw ScreenStateException('Screen State API only available on Android');
  }

  /// Parses the raw event string received from the platform channel into a [ScreenStateEvent] enum value.
  ScreenStateEvent _parseScreenStateEvent(String event) {
    switch (event) {
      // Map platform-specific event strings to corresponding ScreenStateEvent enum values
      case 'android.intent.action.SCREEN_OFF':
        return ScreenStateEvent.SCREEN_OFF;
      case 'android.intent.action.SCREEN_ON':
        return ScreenStateEvent.SCREEN_ON;
      case 'android.intent.action.USER_PRESENT':
        return ScreenStateEvent.SCREEN_UNLOCKED;
      default:
        // Throw an ArgumentError if the event string is not recognized
        throw ArgumentError('$event was not recognized.');
    }
  }
}
