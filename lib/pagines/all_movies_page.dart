import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';
import 'package:proyecto/api/api_keys.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/components/nova_pelicula.dart';
import 'package:proyecto/data/base_de_dades.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

/// Clase que representa una estrella para el fondo estrellado
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

/// CustomPainter para dibujar un campo de estrellas titilantes
class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  StarFieldPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      // Calcula opacidad oscilante para el efecto "twinkle"
      double opacity = 0.5 + 0.5 * sin(animationValue + star.twinkleOffset);
      paint.color = Colors.white.withOpacity(opacity);
      // Posición en pantalla según un porcentaje
      final Offset pos = Offset(star.position.dx * size.width, star.position.dy * size.height);
      canvas.drawCircle(pos, star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// CustomPainter para el efecto de ola en la parte inferior
class WavePainter extends CustomPainter {
  final double wavePhase;
  WavePainter(this.wavePhase);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    double waveHeight = 35.0; // Efecto de ola más notable
    double waveLength = size.width;
    // Comenzamos desde la esquina inferior izquierda
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
  bool shouldRepaint(WavePainter oldDelegate) => oldDelegate.wavePhase != wavePhase;
}

/// Fondo animado con gradiente, cielo estrellado y ola.
/// Se anima el gradiente cada 5 segundos y se animan las estrellas y la ola.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({Key? key}) : super(key: key);

  @override
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
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

    // Definición de gradientes con mayor variedad de tonos y stops
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

    // Cambia gradiente cada 5 segundos
    _gradientTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % gradients.length;
      });
    });

    // Generar estrellas con posición aleatoria, tamaño y offset para titilar
    stars = List.generate(numberOfStars, (_) {
      return Star(
        position: Offset(random.nextDouble(), random.nextDouble()),
        radius: random.nextDouble() * 1.5 + 0.5, // Tamaño entre 0.5 y 2.0
        twinkleOffset: random.nextDouble() * 2 * pi,
      );
    });

    // Controlador para titileo de estrellas (ciclo de 3 segundos, con reversa)
    _starController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _starAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );
    _starController.repeat(reverse: true);

    // Controlador para el efecto de ola (5 segundos, ciclo lineal)
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
    // Usamos AnimatedBuilder para actualizar simultáneamente el gradiente, el fondo estrellado y la ola
    return AnimatedBuilder(
      animation: Listenable.merge([_starAnimation, _waveAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Fondo de gradiente animado
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: gradients[_currentIndex],
              ),
            ),
            // Fondo estrellado
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: StarFieldPainter(
                stars: stars,
                animationValue: _starAnimation.value,
              ),
            ),
            // Efecto de ola en la parte inferior
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

/// Página AllMoviesPage que utiliza el fondo animado actualizado
class AllMoviesPage extends StatefulWidget {
  const AllMoviesPage({super.key});

  @override
  State<AllMoviesPage> createState() => _AllMoviesPageState();
}

class _AllMoviesPageState extends State<AllMoviesPage> {
  final Box _boxHive = Hive.box("box_pelicules");
  BaseDeDades db = BaseDeDades();

  bool editMode = false;
  bool isLoading = true;

  // Paginación y búsqueda
  int _currentPage = 1;
  bool _isLoadingMore = false;
  String _searchQuery = "";

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
        isLoading = false;
      });
      db.actualitzarDades();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error al cargar películas desde la API: $e");
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
        isLoading = false;
      });
      db.actualitzarDades();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error al buscar películas: $e");
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
      });
      db.actualitzarDades();
    } catch (e) {
      debugPrint("Error al cargar más películas: $e");
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> toggleFavoriteFirebase(Map<String, dynamic> movie, bool isFavorite) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final String docId = '${user.uid}_${movie["id"]}';
    final CollectionReference favoritesCollection = FirebaseFirestore.instance.collection("favoritos");
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
                  db.pelicules[index]["titol"] = titleController.text;
                  db.pelicules[index]["descripcio"] = descController.text;
                  db.pelicules[index]["imatge"] = imageController.text;
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
    return Column(
      children: [
        // Campo de búsqueda
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
        // Grid con las películas
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: db.pelicules.length,
            itemBuilder: (context, index) {
              final movie = db.pelicules[index];
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
                      canviaValorCheckbox: (valor) => canviaCheckbox(valor, index),
                      esborraPeli: (ctx) => removePeli(index),
                    ),
                  ),
                  if (editMode)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.white),
                        onPressed: () => _mostrarDialogoEdicionDB(index),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: Barra(
        title: "All Movies",
        username: username,
        onSearchTap: () {
          showSearch(
            context: context,
            delegate: MovieSearchDelegate(),
          );
        },
      ),
      drawer: Draww(username: username),
      body: Stack(
        children: [
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
    );
  }
}

/// SEARCH DELEGATE PARA LA LUPA
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
