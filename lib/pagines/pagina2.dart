import 'package:flutter/material.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:hive/hive.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/components/nova_pelicula.dart';
import 'package:proyecto/data/base_de_dades.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

class Pagina2 extends StatefulWidget {
  const Pagina2({super.key});

  @override
  State<Pagina2> createState() => _Pagina2State();
}

class _Pagina2State extends State<Pagina2> {
  final Box _boxHive = Hive.box("box_pelicules");
  BaseDeDades db = BaseDeDades();

  @override
  void initState() {
    super.initState();
    if (_boxHive.get("box_pelicules") == null) {
      db.crearDadesExemple();
    } else {
      db.carregarDades();
    }
  }

  void canviaCheckbox(bool? valor, int posLlista) {
    setState(() {
      final bool valorActual = db.pelicules[posLlista]["favorito"] ?? false;
      db.pelicules[posLlista]["favorito"] = !valorActual;
    });
    db.actualitzarDades();
  }

  void esborraPeli(int posLlista) {
    setState(() {
      db.pelicules.removeAt(posLlista);
    });
    db.actualitzarDades();
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;

    final List<String> genres = [
      'Acción',
      'Drama',
      'Comedia',
      'Terror',
      'Thriller',
      'Romance',
      'Ciencia Ficción',
      'Fantasía',
      'Aventura',
      'Documental'
    ];

    // Lista de secciones por género
    List<Widget> genreSections = [];
    for (String genre in genres) {
      List<Map<String, dynamic>> existingMoviesForGenre = [];

      if (genre == "Aventura") {
        // "Moby Dick" en Aventura con su imagen original
        existingMoviesForGenre.add({
          "titol": "Moby Dick",
          "descripcio": "Una epopeya marítima basada en la clásica novela de Herman Melville.",
          "imatge": "URL_ORIGINAL_DE_MOBY_DICK", // Usa la URL real de la imagen
          "favorito": false,
        });
      }

      if (genre == "Ciencia Ficción") {
        // "Interstellar" en Ciencia Ficción con su imagen original
        existingMoviesForGenre.add({
          "titol": "Interstellar",
          "descripcio": "Un viaje épico a través del espacio y el tiempo.",
          "imatge": "URL_ORIGINAL_DE_INTERSTELLAR", // Usa la URL real de la imagen
          "favorito": false,
        });
      }

      // Generamos 10 películas adicionales para cada género
      List<Map<String, dynamic>> generatedMovies = List.generate(10, (index) {
        return {
          "titol": "$genre Movie ${index + 1}",
          "descripcio": "Descripción de $genre Movie ${index + 1}",
          "imatge": "https://via.placeholder.com/300x400?text=$genre+Movie+${index + 1}",
          "favorito": false,
        };
      });

      List<Map<String, dynamic>> moviesForGenre = [];
      moviesForGenre.addAll(existingMoviesForGenre);
      moviesForGenre.addAll(generatedMovies);

      genreSections.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                genre,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: moviesForGenre.length,
                  itemBuilder: (context, index) {
                    final movie = moviesForGenre[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetallePelicula(movie: movie),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 150,
                          child: ItemPelicula(
                            textPeli: movie["titol"],
                            descripcio: movie["descripcio"],
                            imatge: movie["imatge"],
                            valorCheckBox: movie["favorito"],
                            canviaValorCheckbox: (_) {}, // No se necesita aquí
                            esborraPeli: (_) {}, // No se necesita aquí
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filtrar "Moby Dick" e "Interstellar" del grid general
    final peliculasFiltradas = db.pelicules.where((pelicula) {
      final titulo = pelicula["titol"];
      return titulo != "Moby Dick" && titulo != "Interstellar";
    }).toList();

    return Scaffold(
      appBar: Barra(username: username),
      drawer: Draww(username: username),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...genreSections,
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemCount: peliculasFiltradas.length,
                itemBuilder: (context, index) {
                  return ItemPelicula(
                    textPeli: peliculasFiltradas[index]["titol"] ?? '',
                    descripcio: peliculasFiltradas[index]["descripcio"] ?? '',
                    imatge: peliculasFiltradas[index]["imatge"] ?? '',
                    valorCheckBox: peliculasFiltradas[index]["favorito"] ?? false,
                    canviaValorCheckbox: (valor) => canviaCheckbox(valor, index),
                    esborraPeli: (context) => esborraPeli(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
