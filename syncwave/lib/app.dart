import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'helpers/navigation_helper.dart';
import 'widgets/widgets.dart';

class SyncWave extends StatelessWidget {
  const SyncWave({super.key, this.themeMode});
  final AdaptiveThemeMode? themeMode;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData( 
        brightness: Brightness.light,
        primarySwatch: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.white,
        navigationBarTheme: const NavigationBarThemeData(
          surfaceTintColor: Colors.black,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
        tooltipTheme:
            const TooltipThemeData(waitDuration: Duration(seconds: 1)),
        iconTheme: IconThemeData(color: Colors.grey.shade600),
        appBarTheme: AppBarTheme(
          toolbarHeight: 72,
          color: Colors.transparent,
          elevation: 0.0,
          // Shadow not used as elevation is 0.0 - using this to inject color of decorators/qaul_nav_bar_decorator.dart:157
          shadowColor: Colors.grey.shade300,
          titleTextStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          iconTheme: IconThemeData(color: Colors.grey.shade600),
          actionsIconTheme: IconThemeData(color: Colors.grey.shade600),
          shape: BorderDirectional(
              bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            foregroundColor: Colors.black,
            // fixedSize: Size(80, 36),
            side: const BorderSide(width: 1, color: Colors.black),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.grey.shade600,
        ),
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        iconTheme: const IconThemeData(color: Colors.white),
        navigationBarTheme: const NavigationBarThemeData(
          surfaceTintColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.black,
        ),
        tooltipTheme:
            const TooltipThemeData(waitDuration: Duration(seconds: 1)),
        appBarTheme: const AppBarTheme(
          toolbarHeight: 72,
          elevation: 0.0,
          color: Color(0xff212121),
          shadowColor: Color(0xff212121),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            foregroundColor: Colors.white,
            // fixedSize: Size(80, 36),
            side: const BorderSide(width: 1, color: Colors.white),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
        ),        
      ),
      initial: themeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) {
            return MaterialApp(
              theme: theme,
              darkTheme: darkTheme,
              debugShowCheckedModeBanner: false,
              initialRoute: NavigationHelper.initial,
              onGenerateRoute: NavigationHelper.onGenerateRoute,
              builder: (context, child) {
                if (Platform.isLinux || Platform.isMacOS) {
                  return child ?? const SizedBox();
                }

                  return ResponsiveBreakpoints.builder(
                    child: child!,
                    breakpoints: const [
                      Breakpoint(start: 0, end: 350, name: "ANDROID"),
                      Breakpoint(start: 351, end: 480, name: MOBILE),
                      Breakpoint(start: 481, end: 680, name: "MOBILE_LANDSCAPE"),
                      Breakpoint(start: 681, end: 800, name: TABLET),
                      Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    ],
                  );
              },
            );
        //   },
        // );
      },
    );
  }
}
