import 'dart:async';
import 'dart:convert';
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

/// Fondo animado con gradiente
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({Key? key}) : super(key: key);

  @override
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground> {
  int _currentIndex = 0;
  late List<Gradient> gradients;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    gradients = [
      const LinearGradient(
        colors: [Colors.red, Colors.black, Colors.grey, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Colors.blue, Colors.grey, Colors.red, Colors.black],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Colors.grey, Colors.blue, Colors.black, Colors.red],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Colors.black, Colors.red, Colors.blue, Colors.grey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    // Cambia gradiente cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % gradients.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 2),
      child: Container(
        key: ValueKey<int>(_currentIndex),
        decoration: BoxDecoration(
          gradient: gradients[_currentIndex],
        ),
      ),
    );
  }
}

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  bool isLoading = true;

  // Listas de películas
  List<Map<String, dynamic>> featuredMovies = [];
  List<Map<String, dynamic>> upcomingMovies = [];
  List<Map<String, dynamic>> topRatedMovies = [];
  List<Map<String, dynamic>> trendingMovies = [];

  // Noticias de cine
  bool isNewsLoading = true;
  List<dynamic> cineNews = [];
  final String newsApiKey = ApiKeys.newsApiKey;
  final String newsEndpoint =
      "https://newsapi.org/v2/everything?q=cine%20OR%20pel%C3%ADcula%20OR%20%22festival%20de%20cine%22&language=es&sortBy=publishedAt";

  @override
  void initState() {
    super.initState();
    _loadAllApiData();
    _fetchNoticiasCine();
  }

  // ================== CARGA DE PELÍCULAS ==================
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

      // Ordenamos featuredMovies por voto para topRated
      topRatedMovies = List.from(featuredMovies)
        ..sort((a, b) =>
            (b["vote_average"] as double).compareTo(a["vote_average"] as double));

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

  // ================== CARGA DE NOTICIAS (NewsAPI) ==================
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

  // ============ ZONA SUPERIOR: Imagen animada (GIF) + texto "INICIO" ============
  Widget _buildTopSection() {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // Imagen animada sobre cine (GIF)
          Image.network(
            "https://media.giphy.com/media/xT9IgG50Fb7Mi0prBC/giphy.gif",
            fit: BoxFit.cover,
            width: double.infinity,
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
          // Texto "INICIO"
          const Positioned(
            left: 16,
            top: 16,
            child: Text(
              "INICIO",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ Divider rojo debajo de la imagen ============
  Widget _buildRedDivider() {
    return Container(
      height: 3,
      color: Colors.redAccent,
    );
  }

  // ============ Sección de películas (usa ItemPelicula sin corazón) ============
  Widget _buildMovieSection(String sectionTitle, List<Map<String, dynamic>> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            sectionTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                    MaterialPageRoute(builder: (context) => DetallePelicula(movie: movie)),
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

  // ============ Secciones de noticias (slider + lista) ============
  Widget _buildNewsSlider() {
    if (isNewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (cineNews.isEmpty) {
      return const Center(
        child: Text("No hay noticias recientes de cine", style: TextStyle(color: Colors.white70)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Noticias Destacadas",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                                  child: const Text("Img no disp.", style: TextStyle(color: Colors.white)),
                                ),
                              )
                            : Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image, color: Colors.white),
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
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => _launchUrl(url),
                                child: const Text(
                                  "Leer más",
                                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
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
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                    // Imagen con errorBuilder
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stack) => Container(
                                color: Colors.grey,
                                alignment: Alignment.center,
                                child: const Text("Img no disp.", style: TextStyle(color: Colors.white)),
                              ),
                            )
                          : Container(
                              color: Colors.grey,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image, color: Colors.white),
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
                              child: const Text("Leer más", style: TextStyle(color: Colors.blueAccent)),
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

  // ============ CONTENIDO COMPLETO ============
  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zona superior con imagen animada
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

  // ============ BUILD PRINCIPAL ============
  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      drawer: Draww(username: username),
      // AppBar gris con línea roja (Barra)
      appBar: Barra(
        title: "Inicio",
        username: username,
        onSearchTap: () {
          // Al pulsar la lupa, abrimos un SearchDelegate
          showSearch(
            context: context,
            delegate: MovieSearchDelegate(),
          );
        },
      ),
      // Fondo animado + contenido
      body: Stack(
        children: [
          const AnimatedGradientBackground(),
          SingleChildScrollView(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}

// ============= SEARCH DELEGATE PARA LA LUPA ==================
class MovieSearchDelegate extends SearchDelegate {
  final TmdbApi tmdbApi = TmdbApi();

  @override
  String get searchFieldLabel => 'Buscar película...';

  @override
  List<Widget> buildActions(BuildContext context) {
    // Botón para limpiar el texto si no está vacío
    if (query.isEmpty) {
      return [];
    } else {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        )
      ];
    }
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Flecha para cerrar el SearchDelegate
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // Mostramos resultados de búsqueda
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
            final poster = posterPath != null && posterPath.isNotEmpty
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
                // Cierra el search y navega a DetallePelicula
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

  // buildSuggestions: sugerencias rápidas mientras se escribe
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Escribe algo para buscar..."));
    }
    // Podemos mostrar los mismos resultados que en buildResults
    return buildResults(context);
  }
}
