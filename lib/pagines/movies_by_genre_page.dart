import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:hive/hive.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/components/nova_pelicula.dart';
import 'package:proyecto/data/base_de_dades.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';

class MoviesByGenrePage extends StatefulWidget {
  const MoviesByGenrePage({super.key});

  @override
  State<MoviesByGenrePage> createState() => _MoviesByGenrePageState();
}

class _MoviesByGenrePageState extends State<MoviesByGenrePage> {
  final Box _boxHive = Hive.box("box_pelicules");
  BaseDeDades db = BaseDeDades();

  bool editMode = false;
  bool isLoading = true;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _searchQuery = "";

  // Mapeo de ID de género a nombre.
  Map<int, String> _genreMapping = {};

  // Agrupación: mapa de género a lista de películas.
  Map<String, List<Map<String, dynamic>>> moviesByGenre = {};

  // ScrollController para la paginación automática.
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cargarPeliculasApi();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Escucha el scroll para detectar cuando se acerca al final.
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _searchQuery.isEmpty) {
      _loadMoreMovies();
    }
  }

  Future<void> _cargarPeliculasApi() async {
    try {
      final tmdbApi = TmdbApi();
      // Carga la primera página de películas y la lista de géneros.
      final rawMovies = await tmdbApi.fetchPopularMovies(page: _currentPage);
      final rawGenres = await tmdbApi.fetchGenres();

      // Construimos el mapeo de ID a nombre de género.
      Map<int, String> genreMapping = {};
      for (var g in rawGenres) {
        genreMapping[g['id']] = g['name'];
      }
      _genreMapping = genreMapping;

      // Convertimos cada película a un Map.
      List<Map<String, dynamic>> moviesFromApi = rawMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        return {
          "id": movie.id,
          "titol": movie.title,
          "descripcio": movie.overview,
          "imatge": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
          "release_date": item["release_date"] ?? "",
          "vote_average": item["vote_average"]?.toString() ?? "",
          "vote_count": item["vote_count"]?.toString() ?? "",
          "popularity": item["popularity"]?.toString() ?? "",
          "original_language": item["original_language"] ?? "",
          "runtime": item["runtime"]?.toString() ?? "",
          "tagline": item["tagline"] ?? "",
          "favorito": false,
          "genre_ids": movie.genreIds,
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

  // Agrupa las películas según su género.
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

  void _searchMovies(String query) async {
    if (query.isEmpty) {
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
          "id": movie.id,
          "titol": movie.title,
          "descripcio": movie.overview,
          "imatge": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
          "release_date": item["release_date"] ?? "",
          "vote_average": item["vote_average"]?.toString() ?? "",
          "vote_count": item["vote_count"]?.toString() ?? "",
          "popularity": item["popularity"]?.toString() ?? "",
          "original_language": item["original_language"] ?? "",
          "runtime": item["runtime"]?.toString() ?? "",
          "tagline": item["tagline"] ?? "",
          "favorito": false,
          "genre_ids": movie.genreIds,
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
      print("Error al buscar películas: $e");
    }
  }

  void _loadMoreMovies() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final tmdbApi = TmdbApi();
      _currentPage++;
      final newMovies = _searchQuery.isEmpty
          ? await tmdbApi.fetchPopularMovies(page: _currentPage)
          : await tmdbApi.searchMovies(query: _searchQuery, page: _currentPage);
      List<Map<String, dynamic>> moviesFromApi = newMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        return {
          "id": movie.id,
          "titol": movie.title,
          "descripcio": movie.overview,
          "imatge": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
          "release_date": item["release_date"] ?? "",
          "vote_average": item["vote_average"]?.toString() ?? "",
          "vote_count": item["vote_count"]?.toString() ?? "",
          "popularity": item["popularity"]?.toString() ?? "",
          "original_language": item["original_language"] ?? "",
          "runtime": item["runtime"]?.toString() ?? "",
          "tagline": item["tagline"] ?? "",
          "favorito": false,
          "genre_ids": movie.genreIds,
        };
      }).toList();
      setState(() {
        db.pelicules.addAll(moviesFromApi);
        _inicializarMoviesByGenre();
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

  // Función para actualizar favoritos en Firebase.
  Future<void> toggleFavoriteFirebase(Map<String, dynamic> movie, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final String docId = '${user.uid}_${movie["id"]}';
    final CollectionReference favoritesCollection =
        FirebaseFirestore.instance.collection("favoritos");
    if (isFavorite) {
      await favoritesCollection.doc(docId).set({
        "userId": user.uid,
        "movie": movie,
        "timestamp": FieldValue.serverTimestamp(),
      });
    } else {
      await favoritesCollection.doc(docId).delete();
    }
  }

  void canviaCheckbox(bool? valor, int posLlista) async {
    final bool valorActual = db.pelicules[posLlista]["favorito"] ?? false;
    final bool nuevoValor = !valorActual;
    setState(() {
      db.pelicules[posLlista]["favorito"] = nuevoValor;
    });
    await toggleFavoriteFirebase(db.pelicules[posLlista], nuevoValor);
  }

  // Función para eliminar película.
  void removePeli(int posLlista) {
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
              _inicializarMoviesByGenre();
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

  void _mostrarDialogoEdicionDB(int index) {
    final movie = db.pelicules[index];
    TextEditingController titleController = TextEditingController(text: movie["titol"]);
    TextEditingController descController = TextEditingController(text: movie["descripcio"]);
    TextEditingController imageController = TextEditingController(text: movie["imatge"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Película"),
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  db.pelicules[index]["titol"] = titleController.text;
                  db.pelicules[index]["descripcio"] = descController.text;
                  db.pelicules[index]["imatge"] = imageController.text;
                  _inicializarMoviesByGenre();
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
        appBar: Barra(username: username),
        drawer: Draww(username: username),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Barra(username: username),
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
      // Se utiliza NotificationListener para detectar el scroll y cargar más películas
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 100 &&
              !_isLoadingMore &&
              _searchQuery.isEmpty) {
            _loadMoreMovies();
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Campo de búsqueda.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrangeAccent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Buscar película...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
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
              ),
              // Se muestran las películas agrupadas por género.
              ...moviesByGenre.entries.map((entry) {
                final genre = entry.key;
                final movieList = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                                        canviaValorCheckbox: (valor) =>
                                            canviaCheckbox(valor, db.pelicules.indexOf(movie)),
                                        esborraPeli: (context) => removePeli(db.pelicules.indexOf(movie)),
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
                                          final globalIndex = db.pelicules.indexOf(movie);
                                          _mostrarDialogoEdicionDB(globalIndex);
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
              // Botón para cargar más películas (opcional si se quiere dar feedback adicional).
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
      ),
    );
  }
}
