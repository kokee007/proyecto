import 'package:flutter/material.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/components/nova_pelicula.dart';
import 'package:proyecto/data/base_de_dades.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';

class AllMoviesPage extends StatefulWidget {
  const AllMoviesPage({super.key});

  @override
  State<AllMoviesPage> createState() => _AllMoviesPageState();
}

class _AllMoviesPageState extends State<AllMoviesPage> {
  final BaseDeDades db = BaseDeDades();
  bool editMode = false;
  bool isLoading = true;

  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    db.carregarDades();
    _cargarPeliculasApi();
  }

  Future<void> _cargarPeliculasApi() async {
    try {
      final tmdbApi = TmdbApi();
      final rawMovies = await tmdbApi.fetchPopularMovies(page: _currentPage);

      List<Map<String, dynamic>> moviesFromApi = rawMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        // Conservamos el estado "favorito" si ya existe en db.pelicules
        bool favoriteStatus = false;
        try {
          final existing =
              db.pelicules.firstWhere((m) => m["titol"] == movie.title);
          favoriteStatus = existing["favorito"] ?? false;
        } catch (e) {
          favoriteStatus = false;
        }
        return {
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
          "favorito": favoriteStatus,
          "genre_ids": movie.genreIds,
        };
      }).toList();

      setState(() {
        db.pelicules = moviesFromApi;
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
        bool favoriteStatus = false;
        try {
          final existing =
              db.pelicules.firstWhere((m) => m["titol"] == movie.title);
          favoriteStatus = existing["favorito"] ?? false;
        } catch (e) {
          favoriteStatus = false;
        }
        return {
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
          "favorito": favoriteStatus,
          "genre_ids": movie.genreIds,
        };
      }).toList();
      setState(() {
        db.pelicules = moviesFromApi;
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
        bool favoriteStatus = false;
        try {
          final existing =
              db.pelicules.firstWhere((m) => m["titol"] == movie.title);
          favoriteStatus = existing["favorito"] ?? false;
        } catch (e) {
          favoriteStatus = false;
        }
        return {
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
          "favorito": favoriteStatus,
          "genre_ids": movie.genreIds,
        };
      }).toList();
      setState(() {
        db.pelicules.addAll(moviesFromApi);
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

  // Función simplificada para cambiar el favorito sin parámetro adicional
  void canviaCheckbox(int posLlista) {
    setState(() {
      db.pelicules[posLlista]["favorito"] =
          !(db.pelicules[posLlista]["favorito"] ?? false);
      print(
          "Película '${db.pelicules[posLlista]["titol"]}' favorito: ${db.pelicules[posLlista]["favorito"]}");
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
          title: const Text("Editar Película"),
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

    final peliculasFiltradas = db.pelicules;

    return Scaffold(
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
            // Grid de películas
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
                            MaterialPageRoute(
                              builder: (context) => DetallePelicula(movie: movie),
                            ),
                          );
                        },
                        child: ItemPelicula(
                          textPeli: movie["titol"] ?? '',
                          descripcio: movie["descripcio"] ?? '',
                          imatge: movie["imatge"] ?? '',
                          valorCheckBox: movie["favorito"] ?? false,
                          // Se llama al callback simplificado sin parámetro adicional
                          canviaValorCheckbox: (_) => canviaCheckbox(index),
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
            // Botón para cargar más películas
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
