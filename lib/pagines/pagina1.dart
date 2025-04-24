import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Ajusta estos imports según tu proyecto
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';
import 'package:proyecto/api/api_keys.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

/// Clase para representar una estrella en el fondo
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

/// Fondo animado con gradiente, estrellas y efecto de ola profesional
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

  // Control de la animación de las estrellas
  late AnimationController _starController;
  late Animation<double> _starAnimation;
  final int numberOfStars = 100;
  late List<Star> stars;
  final Random random = Random();

  // Controlador para el efecto de ola en la parte inferior (opcional)
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // Definición de gradientes con más tonos
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

    // Cambia gradiente cada 4 segundos
    _gradientTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % gradients.length;
      });
    });

    // Generar estrellas con posiciones y parámetros aleatorios
    stars = List.generate(numberOfStars, (_) {
      return Star(
        position: Offset(random.nextDouble(), random.nextDouble()),
        radius: random.nextDouble() * 1.5 + 0.5,
        twinkleOffset: random.nextDouble() * 2 * pi,
      );
    });

    // Controlador para el efecto de titileo en las estrellas
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _starAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeInOut),
    );
    _starController.repeat(reverse: true);

    // Controlador para el efecto de ola
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
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
    // Combina animaciones de gradiente, estrellas y ola
    return AnimatedBuilder(
      animation: Listenable.merge([_starAnimation, _waveAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Fondo gradiente
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              decoration: BoxDecoration(
                gradient: gradients[_currentIndex],
              ),
            ),
            // Estrellas
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: StarFieldPainter(
                stars: stars,
                animationValue: _starAnimation.value,
              ),
            ),
            // Ola inferior
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: const Size(double.infinity, 50),
                painter: WavePainter(_waveAnimation.value),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// CustomPainter para el cielo estrellado
class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  StarFieldPainter({
    required this.stars,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      double opacity = 0.5 + 0.5 * sin(animationValue + star.twinkleOffset);
      paint.color = Colors.white.withOpacity(opacity);
      final Offset position = Offset(
        star.position.dx * size.width,
        star.position.dy * size.height,
      );
      canvas.drawCircle(position, star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// CustomPainter para la ola inferior
class WavePainter extends CustomPainter {
  final double wavePhase;
  WavePainter(this.wavePhase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    const double waveHeight = 30.0;
    final double waveLength = size.width;

    path.moveTo(0, size.height);
    for (double x = 0; x <= waveLength; x++) {
      final double y =
          size.height - waveHeight * sin((2 * pi / waveLength) * x + wavePhase);
      path.lineTo(x, y);
    }
    path.lineTo(waveLength, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) =>
      oldDelegate.wavePhase != wavePhase;
}

/// Lista con 6+ GIFs cinematográficos (¡añade o cambia los que quieras!)
final List<String> topSectionGifs = [
  // Ejemplo de GIFs variados relacionados con cine/animación
  "https://media.giphy.com/media/10LKovKon8DENq/giphy.gif",
  "https://media.giphy.com/media/l0HlAqW2h9YnkR8yY/giphy.gif",
  "https://media.giphy.com/media/26BRzozg4TCBXv6QU/giphy.gif",
  "https://media.giphy.com/media/3o7TKtnuHOHHUjR38Y/giphy.gif",
  "https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif",
  "https://media.giphy.com/media/UoeaPqYrimha6rdTFV/giphy.gif",
  "https://media.giphy.com/media/xT9IgG50Fb7Mi0prBC/giphy.gif",
];

/// Pagina1: selecciona un GIF aleatorio cada vez que entras
class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  bool isLoading = true; // Indica si las pelis se están cargando
  bool isNewsLoading = true; // Indica si las noticias se están cargando

  // Listas de películas
  List<Map<String, dynamic>> featuredMovies = [];
  List<Map<String, dynamic>> upcomingMovies = [];
  List<Map<String, dynamic>> topRatedMovies = [];
  List<Map<String, dynamic>> trendingMovies = [];

  // Lista de noticias
  List<dynamic> cineNews = [];

  // Para el NewsAPI
  final String newsApiKey = ApiKeys.newsApiKey;
  final String newsEndpoint =
      "https://newsapi.org/v2/everything?q=cine%20OR%20pel%C3%ADcula%20OR%20%22festival%20de%20cine%22&language=es&sortBy=publishedAt";

  // Variable para almacenar el GIF seleccionado al azar
  late String selectedGif;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    // Selecciona un GIF al azar cada vez que se reconstruya la pagina
    selectedGif = topSectionGifs[random.nextInt(topSectionGifs.length)];
    _loadAllApiData();
    _fetchNoticiasCine();
  }

  // Carga de películas
  Future<void> _loadAllApiData() async {
    setState(() => isLoading = true);
    try {
      final tmdbApi = TmdbApi();
      final rawFeatured = await tmdbApi.fetchPopularMovies(page: 1);
      final rawUpcoming = await tmdbApi.fetchUpcomingMovies(page: 1);
      final rawTrending = await tmdbApi.fetchPopularMovies(page: 2);

      featuredMovies = _mapMovies(rawFeatured);
      upcomingMovies = _mapMovies(rawUpcoming);
      trendingMovies = _mapMovies(rawTrending);

      // Ordenamos para topRated según el voto
      topRatedMovies = List.from(featuredMovies)
        ..sort((a, b) => (b["vote_average"] as double)
            .compareTo(a["vote_average"] as double));

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error al cargar películas: $e");
    }
  }

  List<Map<String, dynamic>> _mapMovies(List<dynamic> rawMovies) {
    return rawMovies.map((item) {
      final movie = Movie.fromJson(Map<String, dynamic>.from(item));
      return {
        "titol": movie.title,
        "descripcio": movie.overview,
        "imatge": movie.posterPath.isNotEmpty
            ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
            : '',
        "release_date": item["release_date"] ?? "",
        "vote_average":
            double.tryParse(item["vote_average"]?.toString() ?? "0") ?? 0,
      };
    }).toList();
  }

  // Carga de noticias
  Future<void> _fetchNoticiasCine() async {
    setState(() => isNewsLoading = true);
    try {
      final fromDate =
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
      final url = Uri.parse("$newsEndpoint&from=$fromDate&apiKey=$newsApiKey");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cineNews = data["articles"] ?? [];
          isNewsLoading = false;
        });
      } else {
        setState(() => isNewsLoading = false);
        debugPrint("Error al cargar noticias: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isNewsLoading = false);
      debugPrint("Error al cargar noticias: $e");
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("No se pudo abrir $url");
    }
  }

  // =================== TOP SECTION (GIF + "INICIO") ===================
  Widget _buildTopSection() {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Se muestra el GIF aleatorio seleccionado
          
          Image.network(
            selectedGif,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  color: Colors.redAccent,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text(
                  "Imagen no disponible",
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
          // Texto superpuesto "INICIO"
          const Positioned(
            left: 16,
            top: 16,
            child: Text(
              "INICIO",
              style: TextStyle(
                shadows: [
                  Shadow(
                    color: Colors.yellowAccent,
                    blurRadius: 4,
                  ),
                ],
                color: Colors.redAccent,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =================== DIVIDER ROJO ===================
  Widget _buildRedDivider() {
    return Container(
      height: 3,
      color: Colors.redAccent,
    );
  }

  // =================== SECCIONES DE PELÍCULAS ===================
  Widget _buildMovieSection(
      String sectionTitle, List<Map<String, dynamic>> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            sectionTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
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
                    textPeli: movie["titol"] ?? '',
                    descripcio: movie["descripcio"] ?? '',
                    imatge: movie["imatge"] ?? '',
                    showHeart: false,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieSlider(String title, List<Map<String, dynamic>> movies) {
    return _buildMovieSection(title, movies);
  }

  // =================== SECCIONES DE NOTICIAS ===================
  Widget _buildNewsSlider() {
    if (isNewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cineNews.isEmpty) {
      return const Center(
        child: Text("No hay noticias recientes de cine",
            style: TextStyle(color: Colors.white70)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Noticias Destacadas",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cineNews.length,
            itemBuilder: (context, index) {
              final article = cineNews[index];
              final String? imageUrl = article["urlToImage"];
              final String title = article["title"] ?? "Sin título";
              final String description = article["description"] ?? "";
              final String url = article["url"] ?? "#";

              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 140,
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stack) => Container(
                                  color: Colors.grey,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "Img no disp.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image,
                                    color: Colors.white),
                              ),
                      ),
                      Container(
                        height: 100,
                        color: Colors.black87,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => _launchUrl(url),
                                child: const Text(
                                  "Leer más",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsList() {
    if (isNewsLoading) {
      return const SizedBox();
    }
    if (cineNews.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Noticias Recientes",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cineNews.length,
          itemBuilder: (context, index) {
            final article = cineNews[index];
            final String? imageUrl = article["urlToImage"];
            final String title = article["title"] ?? "Sin título";
            final String description = article["description"] ?? "";
            final String url = article["url"] ?? "#";

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stack) => Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Img no disp.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey,
                              alignment: Alignment.center,
                              child:
                                  const Icon(Icons.image, color: Colors.white),
                            ),
                    ),
                    Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _launchUrl(url),
                              child: const Text("Leer más",
                                  style: TextStyle(color: Colors.blueAccent)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // =================== CONTENIDO COMPLETO ===================
  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zona superior con un GIF aleatorio y texto "INICIO"
        _buildTopSection(),
        // Divider rojo
        _buildRedDivider(),
        // Secciones de películas
        _buildMovieSlider("Películas Destacadas", featuredMovies),
        const SizedBox(height: 16),
        _buildMovieSlider("Próximos Estrenos", upcomingMovies),
        const SizedBox(height: 16),
        _buildMovieSlider("Lo Más Valoradas", topRatedMovies),
        const SizedBox(height: 16),
        _buildMovieSlider("Tendencias del Momento", trendingMovies),
        const SizedBox(height: 16),
        // Secciones de noticias
        _buildNewsSlider(),
        const SizedBox(height: 16),
        _buildNewsList(),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      drawer: Draww(username: username),
      appBar: Barra(
        title: "Inicio",
        username: username,
        onSearchTap: () {
          showSearch(
            context: context,
            delegate: MovieSearchDelegate(),
          );
        },
      ),
      // Se utiliza el fondo animado con gradiente, estrellas y ola
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradientBackground()),
          SingleChildScrollView(
            child: _buildContent(),
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
            ),
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
