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

  late AnimationController _starController;
  late Animation<double> _starAnimation;
  final int numberOfStars = 100;
  late List<Star> stars;
  final Random random = Random();

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

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
      // …otros gradientes…
    ];

    _gradientTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % gradients.length;
      });
    });

    stars = List.generate(numberOfStars, (_) {
      return Star(
        position: Offset(random.nextDouble(), random.nextDouble()),
        radius: random.nextDouble() * 1.5 + 0.5,
        twinkleOffset: random.nextDouble() * 2 * pi,
      );
    });

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _starAnimation =
        Tween<double>(begin: 0.0, end: 2 * pi).animate(_starController);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _waveAnimation =
        Tween<double>(begin: 0.0, end: 2 * pi).animate(_waveController);
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
    return AnimatedBuilder(
      animation: Listenable.merge([_starAnimation, _waveAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              decoration: BoxDecoration(
                gradient: gradients[_currentIndex],
              ),
            ),
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _StarFieldPainter(
                stars: stars,
                animationValue: _starAnimation.value,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomPaint(
                size: const Size(double.infinity, 50),
                painter: _WavePainter(_waveAnimation.value),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  _StarFieldPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final star in stars) {
      final opacity = 0.5 + 0.5 * sin(animationValue + star.twinkleOffset);
      paint.color = Colors.white.withOpacity(opacity);
      final pos = Offset(
        star.position.dx * size.width,
        star.position.dy * size.height,
      );
      canvas.drawCircle(pos, star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter old) =>
      old.animationValue != animationValue;
}

class _WavePainter extends CustomPainter {
  final double wavePhase;
  _WavePainter(this.wavePhase);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, size.height);
    const waveHeight = 30.0;
    final waveLength = size.width;
    for (double x = 0; x <= waveLength; x++) {
      final y = size.height -
          waveHeight * sin((2 * pi / waveLength) * x + wavePhase);
      path.lineTo(x, y);
    }
    path.lineTo(waveLength, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) =>
      old.wavePhase != wavePhase;
}

final List<String> topSectionGifs = [
  "https://media.giphy.com/media/10LKovKon8DENq/giphy.gif",
  // …
];

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});
  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  bool isLoading = true;
  bool isNewsLoading = true;

  List<Map<String, dynamic>> featuredMovies = [];
  List<Map<String, dynamic>> upcomingMovies = [];
  List<Map<String, dynamic>> topRatedMovies = [];
  List<Map<String, dynamic>> trendingMovies = [];

  List<dynamic> cineNews = [];
  late String selectedGif;
  final rnd = Random();

  final newsApiKey = ApiKeys.newsApiKey;
  final newsEndpoint =
      "https://newsapi.org/v2/everything?q=cine%20OR%20pel%C3%ADcula&language=es&sortBy=publishedAt";

  @override
  void initState() {
    super.initState();
    selectedGif = topSectionGifs[rnd.nextInt(topSectionGifs.length)];
    _loadAllApiData();
    _fetchNoticiasCine();
  }

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

      topRatedMovies = List.from(featuredMovies)
        ..sort((a, b) =>
            (b["vote_average"] as double).compareTo(a["vote_average"] as double));

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error al cargar películas: $e");
    }
  }

  List<Map<String, dynamic>> _mapMovies(List<dynamic> raw) {
    return raw.map((item) {
      final movie = Movie.fromJson(Map<String, dynamic>.from(item));
      return {
        "id": item["id"], 
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

  Widget _buildTopSection(ThemeData theme) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Image.network(
            selectedGif,
            fit: BoxFit.cover,
            width: double.infinity,
            loadingBuilder: (ctx, child, prog) {
              if (prog == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                  value: prog.expectedTotalBytes != null
                      ? prog.cumulativeBytesLoaded /
                          (prog.expectedTotalBytes ?? 1)
                      : null,
                ),
              );
            },
            errorBuilder: (_, __, ___) {
              return Container(
                color: theme.dividerColor,
                alignment: Alignment.center,
                child: Text(
                  "Imagen no disponible",
                  style: theme.textTheme.bodyMedium,
                ),
              );
            },
          ),
          const Positioned(
            left: 16,
            top: 16,
            child: Text(
              "INICIO",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.yellowAccent, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedDivider() {
    return Container(height: 3, color: Colors.redAccent);
  }

  Widget _buildMovieSection(
      String sectionTitle, List<Map<String, dynamic>> movies) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            sectionTitle,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (ctx, i) {
              final movie = movies[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetallePelicula(movie: movie,key: ValueKey(movie["id"]),
                  ),
                ),),
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

  Widget _buildNewsSlider() {
    final theme = Theme.of(context);
    if (isNewsLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.secondary,
        ),
      );
    }
    if (cineNews.isEmpty) {
      return Center(
        child: Text(
          "No hay noticias recientes de cine",
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.hintColor),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Noticias Destacadas",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cineNews.length,
            itemBuilder: (ctx, i) {
              final art = cineNews[i];
              final imgUrl = art["urlToImage"] as String?;
              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          theme.shadowColor.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: imgUrl != null && imgUrl.isNotEmpty
                            ? Image.network(
                                imgUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        Container(
                                          color:
                                              theme.dividerColor,
                                          alignment:
                                              Alignment.center,
                                          child: Icon(
                                            Icons
                                                .image_not_supported,
                                            color: theme
                                                .iconTheme
                                                .color,
                                          ),
                                        ),
                              )
                            : Container(
                                color:
                                    theme.dividerColor,
                                alignment:
                                    Alignment.center,
                                child: Icon(
                                  Icons.image,
                                  color:
                                      theme.iconTheme.color,
                                ),
                              ),
                      ),
                      Container(
                        height: 100,
                        color: theme.cardColor,
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              art["title"] ?? "Sin título",
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: theme
                                  .textTheme.bodyMedium
                                  ?.copyWith(
                                      fontWeight:
                                          FontWeight
                                              .bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              art["description"] ?? "",
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: theme
                                  .textTheme.bodySmall,
                            ),
                            const Spacer(),
                            Align(
                              alignment:
                                  Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _launchUrl(
                                        art["url"] ??
                                            ""),
                                child: Text(
                                  "Leer más",
                                  style: theme
                                      .textTheme.bodyMedium
                                      ?.copyWith(
                                          color: theme
                                              .colorScheme
                                              .secondary),
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
    final theme = Theme.of(context);
    if (isNewsLoading || cineNews.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Noticias Recientes",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cineNews.length,
          itemBuilder: (ctx, i) {
            final art = cineNews[i];
            final imgUrl = art["urlToImage"] as String?;
            return Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        theme.shadowColor.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: imgUrl != null && imgUrl.isNotEmpty
                          ? Image.network(
                              imgUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) =>
                                      Container(
                                        color:
                                            theme.dividerColor,
                                        alignment:
                                            Alignment.center,
                                        child: Icon(
                                          Icons
                                              .image_not_supported,
                                          color: theme
                                              .iconTheme
                                              .color,
                                        ),
                                      ),
                            )
                          : Container(
                              color:
                                  theme.dividerColor,
                              alignment:
                                  Alignment.center,
                              child: Icon(
                                Icons.image,
                                color:
                                    theme.iconTheme.color,
                              ),
                            ),
                    ),
                    Container(
                      color: theme.cardColor,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            art["title"] ?? "Sin título",
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme.bodyMedium
                                ?.copyWith(
                                    fontWeight:
                                        FontWeight
                                            .bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            art["description"] ?? "",
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment:
                                Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  _launchUrl(
                                      art["url"] ??
                                          ""),
                              child: Text(
                                "Leer más",
                                style: theme
                                    .textTheme.bodyMedium
                                    ?.copyWith(
                                        color: theme
                                            .colorScheme
                                            .secondary),
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
      ],
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.secondary,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSection(theme),
        _buildRedDivider(),
        _buildMovieSection("Películas Destacadas", featuredMovies),
        const SizedBox(height: 16),
        _buildMovieSection("Próximos Estrenos", upcomingMovies),
        const SizedBox(height: 16),
        _buildMovieSection("Lo Más Valoradas", topRatedMovies),
        const SizedBox(height: 16),
        _buildMovieSection("Tendencias del Momento", trendingMovies),
        const SizedBox(height: 16),
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
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradientBackground()),
          SingleChildScrollView(child: _buildContent()),
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
  List<Widget> buildActions(BuildContext context) =>
      query.isEmpty
          ? []
          : [
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => query = '',
              ),
            ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    final theme = Theme.of(context);
    if (query.isEmpty) {
      return Center(
        child: Text(
          "Escribe algo para buscar...",
          style: theme.textTheme.bodyMedium,
        ),
      );
    }
    return FutureBuilder<List<dynamic>>(
      future: tmdbApi.searchMovies(query: query, page: 1),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.secondary,
            ),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Text("Error: ${snap.error}",
                style: theme.textTheme.bodyMedium),
          );
        }
        final results = snap.data ?? [];
        if (results.isEmpty) {
          return Center(
            child: Text("No hay resultados para '$query'",
                style: theme.textTheme.bodyMedium),
          );
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (ctx, i) {
            final item = results[i] as Map<String, dynamic>;
            final title = item["title"] ?? "Sin título";
            final overview = item["overview"] ?? "";
            final posterPath = item["poster_path"] as String? ?? "";
            final poster = posterPath.isNotEmpty
                ? "https://image.tmdb.org/t/p/w200$posterPath"
                : "";
            return ListTile(
              leading: poster.isNotEmpty
                  ? Image.network(
                      poster,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image, color: theme.hintColor),
                    )
                  : Icon(Icons.image, color: theme.hintColor),
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
                close(ctx, null);
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => DetallePelicula(movie: movie),
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
  Widget buildSuggestions(BuildContext context) =>
      buildResults(context);
}
