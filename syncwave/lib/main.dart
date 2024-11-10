import 'package:flutter/material.dart';
import 'dart:async';
import 'package:logging/logging.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:syncwave/app.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    Logger.root.level = kDebugMode ? Level.CONFIG : Level.FINE;

    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    runApp(SyncWave(themeMode: savedThemeMode));
  }, (error, stack) => Logger.root.severe(error, error, stack));
}
