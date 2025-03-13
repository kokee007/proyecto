import 'package:flutter/material.dart';
import 'package:proyecto/pagines/pagina1.dart';
import 'package:proyecto/pagines/pagina2.dart';
import 'package:proyecto/pagines/login.dart';
import 'package:proyecto/pagines/registro.dart';
import 'package:proyecto/pagines/all_movies_page.dart';
import 'package:proyecto/pagines/movies_by_genre_page.dart';
import 'package:proyecto/pagines/favoritos.dart'; // Nueva página de Favoritos
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("box_pelicules");
  await Hive.openBox("box_usuarios");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/registro': (context) => const RegistroPage(),
        '/': (context) => const Pagina1(),
        '/pagina1': (context) => const Pagina1(),
        '/pagina2': (context) => const Pagina2(),
        '/all_movies_page': (context) => const AllMoviesPage(),
        '/movies_by_genre_page': (context) => const MoviesByGenrePage(),
        '/favoritos': (context) => const Favoritos(), // Ruta de Favoritos
      },
    );
  }
}
