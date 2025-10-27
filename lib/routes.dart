import 'package:checkpoint_3/core/auth_guard.dart';
import 'package:checkpoint_3/screens/home_screen.dart';
import 'package:checkpoint_3/screens/intro_screen.dart';
import 'package:checkpoint_3/screens/login_screen.dart';
import 'package:checkpoint_3/screens/newPassword_screen.dart';
import 'package:checkpoint_3/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Routes {
  static const String splash = '/';
  static const String intro = '/intro';
  static const String login = '/login';
  static const String home = '/home';
  static const String newPassword = '/newPassword';

  static Route<dynamic> generateRoute(RouteSettings stt) {
    switch (stt.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case intro:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case home:
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: HomeScreen()),
        );
      case newPassword:
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: NewpasswordScreen()),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Rota não encontrada'))),
        );
    }
  }
}
