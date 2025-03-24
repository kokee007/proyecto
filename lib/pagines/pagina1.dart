import 'package:flutter/material.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> with SingleTickerProviderStateMixin {
  bool isLoading = true;

  // Listas dinámicas obtenidas de la API
  List<Map<String, dynamic>> featuredMovies = [];
  List<Map<String, dynamic>> upcomingMovies = [];
  List<Map<String, dynamic>> topRatedMovies = [];
  List<Map<String, dynamic>> trendingMovies = [];

  // Sección de noticias (dummy, para inspirar contenido futuro)
  final List<Map<String, String>> newsItems = [
    {
      'title': 'Nuevo tráiler que redefine el cine épico',
      'image': 'https://via.placeholder.com/400x200?text=Noticia+1',
      'description': 'Un tráiler espectacular que promete revolucionar la industria.'
    },
    {
      'title': 'Entrevista exclusiva con el visionario director',
      'image': 'https://via.placeholder.com/400x200?text=Noticia+2',
      'description': 'Conoce los secretos detrás de su última superproducción.'
    },
    {
      'title': 'Premios del Cine 2025: ¡Nominados revelados!',
      'image': 'https://via.placeholder.com/400x200?text=Noticia+3',
      'description': 'Descubre quiénes se disputan los galardones más importantes.'
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _loadAllApiData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllApiData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final tmdbApi = TmdbApi();
      if (_searchQuery.isEmpty) {
        // Cargar datos para el modo normal
        final rawFeatured = await tmdbApi.fetchPopularMovies(page: 1);
        final rawUpcoming = await tmdbApi.fetchUpcomingMovies(page: 1);
        final rawTrending = await tmdbApi.fetchPopularMovies(page: 2);

        featuredMovies = rawFeatured.map((item) {
          final movie = Movie.fromJson(Map<String, dynamic>.from(item));
          return {
            "titol": movie.title,
            "descripcio": movie.overview,
            "imatge": movie.posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' : '',
            "release_date": item["release_date"] ?? "",
            "vote_average": double.tryParse(item["vote_average"]?.toString() ?? "0") ?? 0,
          };
        }).toList();

        upcomingMovies = rawUpcoming.map((item) {
          final movie = Movie.fromJson(Map<String, dynamic>.from(item));
          return {
            "titol": movie.title,
            "descripcio": movie.overview,
            "imatge": movie.posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' : '',
            "release_date": item["release_date"] ?? "",
            "vote_average": double.tryParse(item["vote_average"]?.toString() ?? "0") ?? 0,
          };
        }).toList();

        trendingMovies = rawTrending.map((item) {
          final movie = Movie.fromJson(Map<String, dynamic>.from(item));
          return {
            "titol": movie.title,
            "descripcio": movie.overview,
            "imatge": movie.posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' : '',
            "release_date": item["release_date"] ?? "",
            "vote_average": double.tryParse(item["vote_average"]?.toString() ?? "0") ?? 0,
          };
        }).toList();

        // Top Rated: ordenar las películas destacadas por vote_average descendente
        topRatedMovies = List.from(featuredMovies)
          ..sort((a, b) => (b["vote_average"] as double).compareTo(a["vote_average"] as double));
      } else {
        final rawMovies = await tmdbApi.searchMovies(query: _searchQuery, page: 1);
        featuredMovies = rawMovies.map((item) {
          final movie = Movie.fromJson(Map<String, dynamic>.from(item));
          return {
            "titol": movie.title,
            "descripcio": movie.overview,
            "imatge": movie.posterPath.isNotEmpty ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' : '',
            "release_date": item["release_date"] ?? "",
            "vote_average": double.tryParse(item["vote_average"]?.toString() ?? "0") ?? 0,
          };
        }).toList();
        upcomingMovies = [];
        trendingMovies = [];
        topRatedMovies = List.from(featuredMovies)
          ..sort((a, b) => (b["vote_average"] as double).compareTo(a["vote_average"] as double));
      }
      setState(() {
        isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error al cargar datos: $e");
    }
  }

  Widget _buildSection(String sectionTitle, List<Map<String, dynamic>> movies) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(sectionTitle,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
                          builder: (context) =>
                              DetallePelicula(movie: movie)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.network(
                            movie["imatge"],
                            fit: BoxFit.cover,
                            width: 150,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 80, color: Colors.white70),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black87],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Text(
                                movie["titol"],
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text("Últimas Noticias",
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final news = newsItems[index];
                return GestureDetector(
                  onTap: () {
                    // Navegar a la página de detalle de la noticia, si se implementa
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(news["image"]!),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        news["title"]!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Buscar película...",
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.black38,
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (query) {
          setState(() {
            _searchQuery = query;
            isLoading = true;
          });
          _loadAllApiData();
        },
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMovieSlider("Películas Destacadas", featuredMovies),
        const SizedBox(height: 16),
        if (_searchQuery.isEmpty) _buildMovieSlider("Próximos Estrenos", upcomingMovies),
        const SizedBox(height: 16),
        if (_searchQuery.isEmpty) _buildMovieSlider("Lo Más Valoradas", topRatedMovies),
        const SizedBox(height: 16),
        if (_searchQuery.isEmpty) _buildMovieSlider("Tendencias del Momento", trendingMovies),
        const SizedBox(height: 16),
        _buildNewsSection(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMovieSlider(String title, List<Map<String, dynamic>> movies) {
    return _buildSection(title, movies);
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      drawer: Draww(username: username),
      body: CustomScrollView(
        slivers: [
          // SliverAppBar con efecto de colapso
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("Inicio",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    "https://i0.wp.com/imgs.hipertextual.com/wp-content/uploads/2017/03/Captura-de-pantalla-2017-03-30-a-las-11.59.05.png?fit=2012%2C1006&quality=50&strip=all&ssl=1",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.grey),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Opcional: expandir o mostrar el buscador a pantalla completa
                },
              )
            ],
          ),
          // Sección de búsqueda y contenido
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
      appBar: Barra(username: username),
    );
  }
}
