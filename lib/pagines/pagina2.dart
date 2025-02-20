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

  // Controla el modo edición en TODA la pantalla (sliders y grid)
  bool editMode = false;

  // Mapa de listas de películas por género (almacena las películas "generadas" y fijas)
  late Map<String, List<Map<String, dynamic>>> moviesByGenre;

  @override
  void initState() {
    super.initState();
    if (_boxHive.get("box_pelicules") == null) {
      db.crearDadesExemple();
    } else {
      db.carregarDades();
    }
    _inicializarMoviesByGenre();
  }

  // Inicializa las películas de cada género (fijas + generadas)
  void _inicializarMoviesByGenre() {
    moviesByGenre = {
      'Acción': _generarPeliculasEjemplo('Acción'),
      'Drama': _generarPeliculasEjemplo('Drama'),
      'Comedia': _generarPeliculasEjemplo('Comedia'),
      'Terror': _generarPeliculasEjemplo('Terror'),
      'Thriller': _generarPeliculasEjemplo('Thriller'),
      'Romance': _generarPeliculasEjemplo('Romance'),
      'Ciencia Ficción': _generarPeliculasEjemplo('Ciencia Ficción'),
      'Fantasía': _generarPeliculasEjemplo('Fantasía'),
      'Aventura': _generarPeliculasAventura(),
      'Documental': _generarPeliculasEjemplo('Documental'),
    };
  }

  // Genera 10 películas de ejemplo para cada género
  List<Map<String, dynamic>> _generarPeliculasEjemplo(String genre) {
    return List.generate(10, (index) {
      return {
        "titol": "$genre Movie ${index + 1}",
        "descripcio": "Descripción de $genre Movie ${index + 1}",
        "imatge": "https://via.placeholder.com/300x400?text=$genre+Movie+${index + 1}",
        "favorito": false,
      };
    });
  }

  // Películas fijas para Aventura (Moby Dick) y generadas
  List<Map<String, dynamic>> _generarPeliculasAventura() {
    List<Map<String, dynamic>> base = [
      {
        "titol": "Moby Dick",
        "descripcio": "Una epopeya marítima basada en la clásica novela de Herman Melville.",
        "imatge": "URL_ORIGINAL_DE_MOBY_DICK", // Reemplaza con la URL real
        "favorito": false,
      }
    ];
    // Generamos 10 más
    base.addAll(_generarPeliculasEjemplo('Aventura'));
    return base;
  }

  // Editar una película del slider (no persiste en Hive)
  void _editarPeliculaSlider(String genre, int indexInGenre) {
    final movie = moviesByGenre[genre]![indexInGenre];
    TextEditingController titleController =
        TextEditingController(text: movie["titol"]);
    TextEditingController descController =
        TextEditingController(text: movie["descripcio"]);
    TextEditingController imageController =
        TextEditingController(text: movie["imatge"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Película (Slider)"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: "URL Imagen"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  moviesByGenre[genre]![indexInGenre]["titol"] =
                      titleController.text;
                  moviesByGenre[genre]![indexInGenre]["descripcio"] =
                      descController.text;
                  moviesByGenre[genre]![indexInGenre]["imatge"] =
                      imageController.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Para marcar/desmarcar favorito en la base de datos
  void canviaCheckbox(bool? valor, int posLlista) {
    setState(() {
      final bool valorActual = db.pelicules[posLlista]["favorito"] ?? false;
      db.pelicules[posLlista]["favorito"] = !valorActual;
    });
    db.actualitzarDades();
  }

  // Eliminar película de la base de datos
  void esborraPeli(int posLlista) {
    setState(() {
      db.pelicules.removeAt(posLlista);
    });
    db.actualitzarDades();
  }

  // Crear una nueva película en la base de datos
  void crearNovaPeli() {
    showDialog(
      context: context,
      builder: (context) {
        return NovaPelicula(
          tecTextPeli: TextEditingController(),
          tecTextDescripcio: TextEditingController(),
          tecTextImatge: TextEditingController(),
          accioGuardar: (novaPeli) {
            setState(() {
              db.pelicules.add(novaPeli);
            });
            db.actualitzarDades();
            Navigator.of(context).pop();
          },
          accioCancelar: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // Editar una película del grid general (persiste en Hive)
  void _mostrarDialogoEdicionDB(Map<String, dynamic> movie) {
    // Buscamos el índice en la lista original (asumiendo que el título es único)
    final int indice = db.pelicules.indexWhere((p) => p["titol"] == movie["titol"]);
    if (indice == -1) return;

    TextEditingController titleController =
        TextEditingController(text: movie["titol"]);
    TextEditingController descController =
        TextEditingController(text: movie["descripcio"]);
    TextEditingController imageController =
        TextEditingController(text: movie["imatge"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Película (Grid DB)"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Título"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Descripción"),
                ),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: "URL Imagen"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  db.pelicules[indice]["titol"] = titleController.text;
                  db.pelicules[indice]["descripcio"] = descController.text;
                  db.pelicules[indice]["imatge"] = imageController.text;
                });
                db.actualitzarDades();
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;

    // Filtramos "Moby Dick" e "Interstellar" para que no aparezcan en el grid
    final peliculasFiltradas = db.pelicules.where((pelicula) {
      final titulo = pelicula["titol"];
      return titulo != "Moby Dick" && titulo != "Interstellar";
    }).toList();

    return Scaffold(
      appBar: Barra(username: username),
      drawer: Draww(username: username),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón para activar/desactivar modo edición en TODA la pantalla
          FloatingActionButton(
            heroTag: 'toggleEdit',
            mini: true,
            onPressed: () {
              setState(() {
                editMode = !editMode;
              });
            },
            child: Icon(editMode ? Icons.check : Icons.edit),
          ),
          const SizedBox(height: 8),
          // Botón para agregar una nueva película a la DB
          FloatingActionButton(
            heroTag: 'addMovie',
            onPressed: crearNovaPeli,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1) Secciones por género (películas generadas + fijas)
            ...moviesByGenre.entries.map((entry) {
              final genre = entry.key;
              final movieList = entry.value; // lista de películas en ese género
              return Padding(
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
                        itemCount: movieList.length,
                        itemBuilder: (context, index) {
                          final movie = movieList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Stack(
                              children: [
                                InkWell(
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
                                      canviaValorCheckbox: (_) {},
                                      esborraPeli: (_) {},
                                    ),
                                  ),
                                ),
                                // Si editMode está activo, mostramos un botón de edición
                                if (editMode)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                                      onPressed: () {
                                        // Editamos en la lista local (no persiste en DB)
                                        _editarPeliculaSlider(genre, index);
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const Divider(),

            // 2) Grid general de películas (almacenadas en DB), sin Moby Dick ni Interstellar
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
                  final movie = peliculasFiltradas[index];
                  return Stack(
                    children: [
                      ItemPelicula(
                        textPeli: movie["titol"] ?? '',
                        descripcio: movie["descripcio"] ?? '',
                        imatge: movie["imatge"] ?? '',
                        valorCheckBox: movie["favorito"] ?? false,
                        canviaValorCheckbox: (valor) => canviaCheckbox(valor, index),
                        esborraPeli: (context) => esborraPeli(index),
                      ),
                      if (editMode)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                            onPressed: () => _mostrarDialogoEdicionDB(movie),
                          ),
                        ),
                    ],
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
