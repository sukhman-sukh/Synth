import 'package:flutter/cupertino.dart';
import 'package:syncwave/screens/home.dart';
import 'package:syncwave/screens/account_screen.dart';
import 'package:syncwave/screens/master_screen.dart';
import 'package:syncwave/screens/splash_screen.dart';
import 'package:syncwave/screens/client_screen.dart';

class NavigationHelper {
  static const initial = '/';
  static const createAccount = '/createAccount';
  static const home = '/home';
  static const settings = '/settings';
  static const about = '/room';
  static const masterScreen = '/masterScreen';
  static const clientScreen = '/clientScreen';
  static const accountScreen = '/accountScreen';
  static const fileHistory = '/fileHistory';

  static Route<T> _buildRoute<T>(
          final RouteSettings settings, final WidgetBuilder page) =>
      CupertinoPageRoute(builder: page, settings: settings);

  static Route<dynamic> onGenerateRoute(final RouteSettings s) {
    Widget routeWidget = const SizedBox.shrink();
    switch (s.name) {
      case initial:
        routeWidget = PopScope(
          canPop: false,
          child: SplashScreen(),
        );
        break;
      // case createAccount:
      //   routeWidget = PopScope(
      //     canPop: false,
      //     child: CreateAccountScreen(),
      //   );
      //   break;
      case home:
        // WillPopScope handled in build method of HomeScreen -> Custom behavior
        routeWidget = const PopScope(
          canPop: false,
          child: HomeScreen(),
        );
        break;
      case accountScreen:
        routeWidget = const PopScope(
          canPop: false,
          child: AccountScreen(),
        );
        break;
      case masterScreen:
        routeWidget = MasterPage();
        break;
      case clientScreen:
        routeWidget = ClientPage();
        break;
      // case settings:
      //   routeWidget = const SettingsScreen();
      //   break;
      // case about:
      //   routeWidget = const AboutScreen();
      //   break;
      // case support:
      //   routeWidget = const SupportScreen();
      //   break;
      // case fileHistory:
      //   routeWidget = const FileHistoryScreen();
      //   break;
      default:
        throw ArgumentError.value(
            s.name, 'Route name', 'Handle this route in NavigationHelper.');
    }

    return _buildRoute(s, (context) => routeWidget);
  }
}
