import 'package:flutter/material.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  bool isLoading = true;

  // Variables para almacenar datos de la API usando claves consistentes:
  // "titol", "descripcio", "imatge" y campos adicionales.
  List<Map<String, dynamic>> featuredMovies = [];
  List<Map<String, dynamic>> upcomingMovies = [];

  // Datos estáticos para otras secciones
  final List<Map<String, String>> recentActivity = List.generate(
    5,
    (index) => {
      'username': 'Alan ${index + 1}',
      'activity': "Revisó la película 'Título de Película'",
    },
  );
  final List<Map<String, String>> popularReviews = [
    {
      'username': 'CineFan1',
      'avatar': 'https://via.placeholder.com/150?text=User1',
      'review': 'Una película impresionante que combina acción y drama de forma magistral.',
    },
    {
      'username': 'MovieLover',
      'avatar': 'https://via.placeholder.com/150?text=User2',
      'review': 'La narrativa visual y la música te sumergen en un mundo único.',
    },
    {
      'username': 'Critico2020',
      'avatar': 'https://via.placeholder.com/150?text=User3',
      'review': 'Una obra maestra con giros inesperados y personajes memorables.',
    },
  ];
  final List<Map<String, String>> communityLists = [
    {
      'title': 'Clásicos del Cine',
      'image': 'https://via.placeholder.com/300x200?text=Clásicos',
    },
    {
      'title': 'Acción y Aventura',
      'image': 'https://via.placeholder.com/300x200?text=Acción',
    },
    {
      'title': 'Drama y Suspenso',
      'image': 'https://via.placeholder.com/300x200?text=Drama',
    },
  ];
  final List<Map<String, String>> popularGenres = [
    {
      'name': 'Acción',
      'image': 'https://via.placeholder.com/300x200?text=Acción',
    },
    {
      'name': 'Drama',
      'image': 'https://via.placeholder.com/300x200?text=Drama',
    },
    {
      'name': 'Comedia',
      'image': 'https://via.placeholder.com/300x200?text=Comedia',
    },
    {
      'name': 'Terror',
      'image': 'https://via.placeholder.com/300x200?text=Terror',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosApi();
  }

  Future<void> _cargarDatosApi() async {
    try {
      final tmdbApi = TmdbApi();
      // Cargamos películas populares (para "Películas Destacadas")
      final rawFeatured = await tmdbApi.fetchPopularMovies(page: 1);
      // Cargamos próximos estrenos
      final rawUpcoming = await tmdbApi.fetchUpcomingMovies(page: 1);

      // Convertimos cada película en un Map usando las claves "titol", "descripcio", "imatge" y campos adicionales
      List<Map<String, dynamic>> tempFeatured = rawFeatured.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
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
          // Puedes incluir "runtime" o "tagline" si están disponibles
          "runtime": item["runtime"]?.toString() ?? "",
          "tagline": item["tagline"] ?? "",
          "favorito": false,
        };
      }).toList();

      List<Map<String, dynamic>> tempUpcoming = rawUpcoming.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
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
          "favorito": false,
        };
      }).toList();

      setState(() {
        featuredMovies = tempFeatured;
        upcomingMovies = tempUpcoming;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error al cargar datos de la API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recuperamos el nombre del usuario (argumento de la ruta)
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: Barra(username: username),
      drawer: Draww(username: username),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Banner Principal (estático)
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://i0.wp.com/imgs.hipertextual.com/wp-content/uploads/2017/03/Captura-de-pantalla-2017-03-30-a-las-11.59.05.png?fit=2012%2C1006&quality=50&strip=all&ssl=1",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: const Center(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 2. Películas Destacadas (Slider) usando datos de la API
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Películas Destacadas',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 250,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: PageView.builder(
                      itemCount: featuredMovies.length,
                      controller: PageController(viewportFraction: 0.8),
                      itemBuilder: (context, index) {
                        final movie = featuredMovies[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  movie["imatge"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error, size: 80),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.black54,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                // InkWell para detectar el tap y navegar al detalle
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetallePelicula(movie: movie),
                                      ),
                                    );
                                  },
                                  child: Container(), // Contenedor transparente para captar el tap
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Text(
                                    movie["titol"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 5,
                                          color: Colors.black,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 3. Actividad Reciente (estática)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Actividad Reciente',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recentActivity.length,
                    itemBuilder: (context, index) {
                      final activity = recentActivity[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                        ),
                        title: Text(activity['username']!),
                        subtitle: Text(activity['activity']!),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 4. Reseñas Populares (estática)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Reseñas Populares',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularReviews.length,
                      itemBuilder: (context, index) {
                        final review = popularReviews[index];
                        return Container(
                          width: 250,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(review['avatar']!),
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review['username']!,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review['review']!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 5. Listas de la Comunidad (estática)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Listas de la Comunidad',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: communityLists.length,
                      itemBuilder: (context, index) {
                        final list = communityLists[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    list['image']!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                list['title']!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 6. Próximos Estrenos (Slider) usando datos de la API
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Próximos Estrenos',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 250,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: PageView.builder(
                      itemCount: upcomingMovies.length,
                      controller: PageController(viewportFraction: 0.8),
                      itemBuilder: (context, index) {
                        final movie = upcomingMovies[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  movie["imatge"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error, size: 80),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, Colors.black54],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                // InkWell para detectar el tap y navegar al detalle
                                InkWell(
                                  onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DetallePelicula(movie: movie)),
                          );
                        },
                                  child: Container(),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Text(
                                    movie["titol"],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 5,
                                          color: Colors.black,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 7. Géneros Populares (estática)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Géneros Populares',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularGenres.length,
                      itemBuilder: (context, index) {
                        final genre = popularGenres[index];
                        return Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    genre['image']!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                genre['name']!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
