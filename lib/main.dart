import 'package:checkpoint_3/firebase_options.dart';
import 'package:checkpoint_3/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class AppMagicColors {
  static const primary = Color(0xFF8B5CF6); // roxo arcano
  static const gold = Color(0xFFE3B341); // dourado leve
  static const bg = Color(0xFFFAF8F5); // pergaminho
  static const card = Color(0xFFF2EEE9); // marfim
  static const text = Color(0xFF1E1E1E); // texto principal
  static const text2 = Color(0xFF5E5E5E); // texto secundário
  static const success = Color(0xFF3BB273); // verde de sucesso
  static const error = Color(0xFFC94E4E); // vermelho de erro
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Grimório de Senhas',
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.generateRoute,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAF8F5), // fundo padrão
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8B5CF6),
          secondary: Color(0xFFE3B341),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1E1E1E)),
          bodyMedium: TextStyle(color: Color(0xFF5E5E5E)),
        ),
        fontFamily: 'Poppins',
      ),
    );
  }
}
