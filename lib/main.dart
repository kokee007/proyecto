import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/firebase_options.dart';
import 'package:proyecto/pagines/favoritos.dart';
import 'package:proyecto/pagines/llistes.dart';
import 'package:proyecto/pagines/noticias.dart'; // Importa la página de noticias
import 'package:proyecto/pagines/pagina1.dart';
import 'package:proyecto/pagines/login.dart';
import 'package:proyecto/pagines/registro.dart';
import 'package:proyecto/pagines/all_movies_page.dart';
import 'package:proyecto/pagines/movies_by_genre_page.dart';
import 'package:proyecto/pagines/configuracion.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 1️⃣ Global theme notifier, defaulting to dark:
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox("box_pelicules");
  await Hive.openBox("box_usuarios");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.redAccent,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.redAccent,
            scaffoldBackgroundColor: Colors.grey.shade900,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black87,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginPage(),
            '/registro': (context) => const RegistroPage(),
            '/': (context)     => const Pagina1(),
            '/pagina1': (ctx) => const Pagina1(),
            '/all_movies_page':    (ctx) => const AllMoviesPage(),
            '/movies_by_genre_page': (ctx) => const MoviesByGenrePage(),
            '/noticias':      (ctx) => const Noticias(),
            '/favoritos':     (ctx) => const FavoritosPage(),
            '/configuracion': (ctx) => const ConfiguracionPage(),
          },
        );
        '/llistes': (context) => const Llistes(),
      },
    );
  }
}
