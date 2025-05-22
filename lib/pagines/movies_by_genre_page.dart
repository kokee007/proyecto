import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/components/nova_pelicula.dart';
import 'package:proyecto/data/base_de_dades.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

/// -------------------------
/// Clases para el fondo animado
/// -------------------------

/// Clase que representa una estrella para el fondo estrellado.
class Star {
  final Offset position;
  final double radius;
  final double twinkleOffset;
  Star({
    required this.position,
    required this.radius,
    required this.twinkleOffset,
  });
}

/// CustomPainter para dibujar el campo de estrellas titilantes.
class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  StarFieldPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      // Se calcula una opacidad oscilante para el efecto de titileo.
      double opacity = 0.5 + 0.5 * sin(animationValue + star.twinkleOffset);
      paint.color = Colors.white.withOpacity(opacity);
      // La posición de la estrella se escala con el tamaño de la pantalla.
      final Offset pos = Offset(star.position.dx * size.width, star.position.dy * size.height);
      canvas.drawCircle(pos, star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// CustomPainter para dibujar un efecto de ola en la parte inferior.
class WavePainter extends CustomPainter {
  final double wavePhase;
  WavePainter(this.wavePhase);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final Path path = Path();
    double waveHeight = 35.0; // Mayor altura para un efecto más notable
    double waveLength = size.width;
    path.moveTo(0, size.height);
    for (double x = 0; x <= waveLength; x++) {
      double y = size.height - waveHeight * sin((2 * pi / waveLength) * x + wavePhase);
      path.lineTo(x, y);
    }
    path.lineTo(waveLength, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) =>
      oldDelegate.wavePhase != wavePhase;
}

/// Fondo animado que combina un gradiente animado (con más tonos y stops personalizados),
/// un cielo estrellado titilante y un sutil efecto de ola en la parte inferior.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({Key? key}) : super(key: key);

  @override
  _AnimatedGradientBackgroundState createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<LinearGradient> gradients;
  late Timer _gradientTimer;

  // Animación para las estrellas
  late AnimationController _starController;
  late Animation<double> _starAnimation;
  final int numberOfStars = 100;
  late List<Star> stars;
  final Random random = Random();

  // Animación para el efecto de ola
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    // Definición de gradientes con más tonos y stops para transiciones suaves.
    gradients = [
      LinearGradient(
        colors: [
          Colors.black,
          Colors.grey.shade900,
          Colors.red.shade700,
          Colors.deepOrange,
          Colors.blue.shade800,
          Colors.blue,
        ],
        stops: const [0.0, 0.2, 0.45, 0.6, 0.85, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [
          Colors.blue.shade900,
          Colors.indigo,
          Colors.purple,
          Colors.red.shade600,
          Colors.black,
          Colors.grey.shade800,
        ],
        stops: const [0.0, 0.15, 0.35, 0.55, 0.75, 1.0],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      LinearGradient(
        colors: [
          Colors.grey.shade800,
          Colors.blue.shade800,
          Colors.blue,
          Colors.teal,
          Colors.green.shade800,
          Colors.black,
        ],
        stops: const [0.0, 0.18, 0.4, 0.62, 0.8, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      LinearGradient(
        colors: [
          Colors.deepPurpleAccent,
          Colors.pink.shade200,
          Colors.red.shade300,
          Colors.orange,
          Colors.yellow.shade700,
          Colors.black,
        ],
        stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ];

    // Cambia gradiente cada 5 segundos.
    _gradientTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % gradients.length;
      });
    });

    // Generamos estrellas con posición, tamaño y offset aleatorios para titilar.
    stars = List.generate(numberOfStars, (_) {
      return Star(
        position: Offset(random.nextDouble(), random.nextDouble()),
        radius: random.nextDouble() * 1.5 + 0.5,
        twinkleOffset: random.nextDouble() * 2 * pi,
      );
    });

    // Controlador para el titileo de las estrellas (ciclo de 3 segundos, con reversa).
    _starController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _starAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );
    _starController.repeat(reverse: true);

    // Controlador para el efecto de ola (5 segundos, ciclo lineal).
    _waveController = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _waveAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
    _waveController.repeat();
  }

  @override
  void dispose() {
    _gradientTimer.cancel();
    _starController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un AnimatedBuilder para que el fondo se actualice a la vez que las animaciones de estrellas y ola.
    return AnimatedBuilder(
      animation: Listenable.merge([_starAnimation, _waveAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Fondo de gradiente animado.
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: gradients[_currentIndex],
              ),
            ),
            // Fondo estrellado.
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: StarFieldPainter(
                stars: stars,
                animationValue: _starAnimation.value,
              ),
            ),
            // Efecto de ola en la parte inferior.
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: const Size(double.infinity, 60),
                painter: WavePainter(_waveAnimation.value),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// -------------------------
/// Página MoviesByGenrePage usando el fondo animado
/// -------------------------
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
  Map<int, String> _genreMapping = {};
  Map<String, List<Map<String, dynamic>>> moviesByGenre = {};

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
      final rawMovies = await tmdbApi.fetchPopularMovies(page: _currentPage);
      final rawGenres = await tmdbApi.fetchGenres();

      // Construcción del mapa de géneros.
      Map<int, String> genreMapping = {};
      for (var g in rawGenres) {
        genreMapping[g['id']] = g['name'];
      }
      _genreMapping = genreMapping;

      // Mapeo de películas.
      List<Map<String, dynamic>> moviesFromApi = rawMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        return {
          "id": movie.id,
          "titol": movie.title,
          "descripcio": movie.overview,
          "imatge": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
          "favorito": false,
          "genre_ids": movie.genreIds,
          "release_date": item["release_date"] ?? "",
          "vote_average": item["vote_average"]?.toString() ?? "",
          "vote_count": item["vote_count"]?.toString() ?? "",
          "popularity": item["popularity"]?.toString() ?? "",
          "original_language": item["original_language"] ?? "",
          "runtime": item["runtime"]?.toString() ?? "",
          "tagline": item["tagline"] ?? "",
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

  void _inicializarMoviesByGenre() {
    moviesByGenre = {};
    for (var movie in db.pelicules) {
      List<dynamic> genreIds = movie["genre_ids"] ?? [];
      for (var id in genreIds) {
        final genreName = _genreMapping[id] ?? "Sin género";
        moviesByGenre.putIfAbsent(genreName, () => []);
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
          "favorito": false,
          "genre_ids": movie.genreIds,
          "release_date": item["release_date"] ?? "",
          "vote_average": item["vote_average"]?.toString() ?? "",
          "vote_count": item["vote_count"]?.toString() ?? "",
          "popularity": item["popularity"]?.toString() ?? "",
          "original_language": item["original_language"] ?? "",
          "runtime": item["runtime"]?.toString() ?? "",
          "tagline": item["tagline"] ?? "",
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
          "favorito": false,
          "genre_ids": movie.genreIds,
          "release_date": item["release_date"] ?? "",
          "vote_average": item["vote_average"]?.toString() ?? "",
          "vote_count": item["vote_count"]?.toString() ?? "",
          "popularity": item["popularity"]?.toString() ?? "",
          "original_language": item["original_language"] ?? "",
          "runtime": item["runtime"]?.toString() ?? "",
          "tagline": item["tagline"] ?? "",
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

  void canviaCheckbox(bool? valor, int posLlista) async {
    final bool valorActual = db.pelicules[posLlista]["favorito"] ?? false;
    final bool nuevoValor = !valorActual;
    setState(() {
      db.pelicules[posLlista]["favorito"] = nuevoValor;
    });
    // Actualización en Firebase se podría agregar si fuera necesario.
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

  Widget _buildContent() {
    final bool isSearching = _searchQuery.isNotEmpty;
    final peliculasFiltradas = db.pelicules;

    return Column(
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
        // Si se está buscando, muestra un grid sin agrupar
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
                childAspectRatio: 0.65,
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
          // Si no se está buscando, se muestran las películas agrupadas por género
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
        // Sección: Grid general de películas
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
              childAspectRatio: 0.65,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      // Fondo transparente para que se vea el fondo animado
      backgroundColor: Colors.transparent,
      appBar: Barra(username: username, title: "Movies by Genre"),
      drawer: Draww(username: username),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'toggleEdit',
            mini: true,
            backgroundColor: Colors.deepOrangeAccent,
            onPressed: () {
              setState(() {
                editMode = !editMode;
              });
            },
            child: Icon(editMode ? Icons.check : Icons.edit, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'addMovie',
            backgroundColor: Colors.deepOrangeAccent,
            onPressed: crearNovaPeli,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo animado con gradiente, estrellas y ola – ocupando toda la pantalla
          const Positioned.fill(child: AnimatedGradientBackground()),
          NotificationListener<ScrollNotification>(
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
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class MovieSearchDelegate extends SearchDelegate {
  final TmdbApi tmdbApi = TmdbApi();
  @override
  String get searchFieldLabel => 'Buscar película...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isEmpty
        ? []
        : [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
              },
            )
          ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Escribe algo para buscar..."));
    }
    return FutureBuilder<List<dynamic>>(
      future: tmdbApi.searchMovies(query: query, page: 1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return Center(child: Text("No hay resultados para '$query'"));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index] as Map<String, dynamic>;
            final title = item["title"] ?? "Sin título";
            final overview = item["overview"] ?? "";
            final posterPath = item["poster_path"];
            final poster = (posterPath != null && posterPath.isNotEmpty)
                ? "https://image.tmdb.org/t/p/w200$posterPath"
                : "";
            return ListTile(
              leading: poster.isNotEmpty
                  ? Image.network(
                      poster,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) =>
                          const Icon(Icons.image, color: Colors.grey),
                    )
                  : const Icon(Icons.image, color: Colors.grey),
              title: Text(title),
              subtitle: Text(
                overview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                final movie = {
                  "id": item["id"],
                  "titol": title,
                  "descripcio": overview,
                  "imatge": poster,
                  "release_date": item["release_date"] ?? "",
                  "vote_average": item["vote_average"] ?? 0.0,
                };
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetallePelicula(movie: movie),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Escribe algo para buscar..."));
    }
    return buildResults(context);
  }
}
