import 'package:flutter/material.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:hive/hive.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/components/nova_pelicula.dart';
import 'package:proyecto/data/base_de_dades.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

// Importa el servicio de TMDb y el modelo Movie
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';

class Pagina2 extends StatefulWidget {
  const Pagina2({super.key});

  @override
  State<Pagina2> createState() => _Pagina2State();
}

class _Pagina2State extends State<Pagina2> {
  final Box _boxHive = Hive.box("box_pelicules");
  BaseDeDades db = BaseDeDades();

  // Controla el modo edición en toda la pantalla
  bool editMode = false;
  bool isLoading = true;

  // Variables para la paginación
  int _currentPage = 1;
  bool _isLoadingMore = false;

  // Campo de búsqueda
  String _searchQuery = "";

  // Mapa para agrupar las películas por género
  Map<String, List<Map<String, dynamic>>> moviesByGenre = {};

  // Mapeo de ID de género a nombre obtenido de la API
  Map<int, String> _genreMapping = {};

  @override
  void initState() {
    super.initState();
    _cargarPeliculasApi();
  }

  Future<void> _cargarPeliculasApi() async {
    try {
      final tmdbApi = TmdbApi();
      // Obtenemos la primera página de películas y la lista de géneros
      final rawMovies = await tmdbApi.fetchPopularMovies(page: _currentPage);
      final rawGenres = await tmdbApi.fetchGenres();

      // Construimos el mapeo de ID a nombre de género
      Map<int, String> genreMapping = {};
      for (var g in rawGenres) {
        genreMapping[g['id']] = g['name'];
      }
      _genreMapping = genreMapping;

      // Convertimos cada película a un Map con la estructura que usa la app
      List<Map<String, dynamic>> moviesFromApi = rawMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        return {
          "titol": movie.title,
          "descripcio": movie.overview,
          "imatge": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
          "favorito": false,
          "genre_ids": movie.genreIds, // Lista de IDs de géneros
        };
      }).toList();

      setState(() {
        db.pelicules = moviesFromApi;
        _inicializarMoviesByGenre();
        isLoading = false;
      });
      db.actualitzarDades();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error al cargar películas desde la API: $e");
    }
  }

  // Función para buscar películas según un query
  void _searchMovies(String query) async {
    if (query.isEmpty) {
      // Si se borra la búsqueda, recargamos las películas populares
      _currentPage = 1;
      _searchQuery = "";
      _cargarPeliculasApi();
      return;
    }

    setState(() {
      isLoading = true;
      _searchQuery = query;
    });

    try {
      final tmdbApi = TmdbApi();
      final rawMovies = await tmdbApi.searchMovies(query: query, page: 1);
      List<Map<String, dynamic>> moviesFromApi = rawMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        return {
          "titol": movie.title,
          "descripcio": movie.overview,
          "imatge": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
          "favorito": false,
          "genre_ids": movie.genreIds,
        };
      }).toList();

      setState(() {
        db.pelicules = moviesFromApi;
        // Cuando hay búsqueda, no agrupamos por género
        moviesByGenre = {};
        isLoading = false;
      });
      db.actualitzarDades();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error al buscar películas: $e");
    }
  }

  // Función para cargar más películas (paginación)
  void _loadMoreMovies() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final tmdbApi = TmdbApi();
      _currentPage++; // Incrementa la página para la siguiente solicitud
      final newMovies = _searchQuery.isEmpty
          ? await tmdbApi.fetchPopularMovies(page: _currentPage)
          : await tmdbApi.searchMovies(query: _searchQuery, page: _currentPage);
      List<Map<String, dynamic>> moviesFromApi = newMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        return {
          "titol": movie.title,
          "descripcio": movie.overview,
          "imatge": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
          "favorito": false,
          "genre_ids": movie.genreIds,
        };
      }).toList();

      setState(() {
        db.pelicules.addAll(moviesFromApi);
        if (_searchQuery.isEmpty) {
          _inicializarMoviesByGenre();
        }
      });
      db.actualitzarDades();
    } catch (e) {
      print("Error al cargar más películas: $e");
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Agrupa las películas en db.pelicules según su género
  void _inicializarMoviesByGenre() {
    moviesByGenre = {};
    for (var movie in db.pelicules) {
      List<dynamic> genreIds = movie["genre_ids"] ?? [];
      for (var id in genreIds) {
        final genreName = _genreMapping[id] ?? "Sin género";
        if (!moviesByGenre.containsKey(genreName)) {
          moviesByGenre[genreName] = [];
        }
        moviesByGenre[genreName]!.add(movie);
      }
    }
  }

  // Funciones de edición, creación y eliminación (se mantienen similares)
  void _editarPeliculaSlider(String genre, int indexInGenre) {
    final movie = moviesByGenre[genre]![indexInGenre];
    TextEditingController titleController = TextEditingController(text: movie["titol"]);
    TextEditingController descController = TextEditingController(text: movie["descripcio"]);
    TextEditingController imageController = TextEditingController(text: movie["imatge"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Película (Slider)"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Título")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Descripción")),
                TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Imagen")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  moviesByGenre[genre]![indexInGenre]["titol"] = titleController.text;
                  moviesByGenre[genre]![indexInGenre]["descripcio"] = descController.text;
                  moviesByGenre[genre]![indexInGenre]["imatge"] = imageController.text;
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
              if (_searchQuery.isEmpty) {
                _inicializarMoviesByGenre();
              }
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

  void _mostrarDialogoEdicionDB(Map<String, dynamic> movie) {
    final int indice = db.pelicules.indexWhere((p) => p["titol"] == movie["titol"]);
    if (indice == -1) return;

    TextEditingController titleController = TextEditingController(text: movie["titol"]);
    TextEditingController descController = TextEditingController(text: movie["descripcio"]);
    TextEditingController imageController = TextEditingController(text: movie["imatge"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Película (Grid DB)"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: "Título")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Descripción")),
                TextField(controller: imageController, decoration: const InputDecoration(labelText: "URL Imagen")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  db.pelicules[indice]["titol"] = titleController.text;
                  db.pelicules[indice]["descripcio"] = descController.text;
                  db.pelicules[indice]["imatge"] = imageController.text;
                  if (_searchQuery.isEmpty) {
                    _inicializarMoviesByGenre();
                  }
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
    if (isLoading) {
      return Scaffold(
        appBar: Barra(username: username, title: "Películas"),
        drawer: Draww(username: username),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Si hay búsqueda (_searchQuery no está vacío) mostramos un grid sin agrupar
    final bool isSearching = _searchQuery.isNotEmpty;
    final peliculasFiltradas = db.pelicules;

    return Scaffold(
      appBar: Barra(username: username, title: "Películas"),
      drawer: Draww(username: username),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Buscar película",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = "";
                      });
                      _currentPage = 1;
                      _cargarPeliculasApi();
                    },
                  ),
                ),
                onSubmitted: (query) {
                  _searchMovies(query);
                },
                onChanged: (query) {
                  if (query.isEmpty) {
                    _currentPage = 1;
                    _searchMovies("");
                  }
                },
              ),
            ),
            // Si estamos buscando, mostramos solo un grid sin agrupar
            if (isSearching)
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
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DetallePelicula(movie: movie)),
                            );
                          },
                          child: ItemPelicula(
                            textPeli: movie["titol"] ?? '',
                            descripcio: movie["descripcio"] ?? '',
                            imatge: movie["imatge"] ?? '',
                            valorCheckBox: movie["favorito"] ?? false,
                            canviaValorCheckbox: (valor) => canviaCheckbox(valor, index),
                            esborraPeli: (context) => esborraPeli(index),
                          ),
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
              )
            else ...[
              // Si no hay búsqueda, mostramos las películas agrupadas por género
              ...moviesByGenre.entries.map((entry) {
                final genre = entry.key;
                final movieList = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(genre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                        MaterialPageRoute(builder: (context) => DetallePelicula(movie: movie)),
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
                                  if (editMode)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                                        onPressed: () {
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
              }),
            ],
            const Divider(),
            // Sección: Grid general de películas (siempre se muestra, se podría ocultar si se busca)
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
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetallePelicula(movie: movie)),
                          );
                        },
                        child: ItemPelicula(
                          textPeli: movie["titol"] ?? '',
                          descripcio: movie["descripcio"] ?? '',
                          imatge: movie["imatge"] ?? '',
                          valorCheckBox: movie["favorito"] ?? false,
                          canviaValorCheckbox: (valor) => canviaCheckbox(valor, index),
                          esborraPeli: (context) => esborraPeli(index),
                        ),
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
            // Botón para cargar más películas (paginación)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _loadMoreMovies,
                child: _isLoadingMore
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Cargar más películas"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
