import 'package:flutter/material.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';

class Pagina1 extends StatefulWidget {
  const Pagina1({super.key});

  @override
  State<Pagina1> createState() => _Pagina1State();
}

class _Pagina1State extends State<Pagina1> {
  // Datos de ejemplo para Películas Destacadas (Slider)
  final List<Map<String, String>> featuredMovies = [
    {
      'title': 'Inception',
      'image': 'https://via.placeholder.com/300x400?text=Inception',
    },
    {
      'title': 'The Matrix',
      'image': 'https://via.placeholder.com/300x400?text=The+Matrix',
    },
    {
      'title': 'Interstellar',
      'image': 'https://via.placeholder.com/300x400?text=Interstellar',
    },
  ];

  // Datos de ejemplo para Actividad Reciente
  final List<Map<String, String>> recentActivity = List.generate(
      5,
      (index) => {
            'username': 'Usuario ${index + 1}',
            'activity': "Revisó la película 'Título de Película'"
          });

  // Datos de ejemplo para Reseñas Populares (Slider)
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

  // Datos de ejemplo para Listas de la Comunidad (Slider)
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

  // Datos de ejemplo para Próximos Estrenos (Slider)
  final List<Map<String, String>> upcomingMovies = [
    {
      'title': 'Avatar 3',
      'image': 'https://via.placeholder.com/300x400?text=Avatar+3',
    },
    {
      'title': 'Matrix Resurrections',
      'image': 'https://via.placeholder.com/300x400?text=Matrix+Resurrections',
    },
    {
      'title': 'Spider-Man: No Way Home',
      'image': 'https://via.placeholder.com/300x400?text=Spider-Man',
    },
  ];

  // Datos de ejemplo para Géneros Populares
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
  Widget build(BuildContext context) {
    // Recuperamos el nombre del usuario (si se pasó como argumento)
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: Barra(username: username),
      drawer: Draww(username: username),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner Principal
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/600x250?text=Cine+Comunidad"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                ),
                child: Center(
                  child: Text(
                    'Bienvenido a Film-Reviewer4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 2. Películas Destacadas (Slider con PageView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            movie['image']!,
                            fit: BoxFit.cover,
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
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Text(
                              movie['title']!,
                              style: TextStyle(
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
            // 3. Actividad Reciente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage("https://via.placeholder.com/150"),
                  ),
                  title: Text(activity['username']!),
                  subtitle: Text(activity['activity']!),
                  onTap: () {
                    // Acción al hacer tap
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            // 4. Reseñas Populares (Slider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            // 5. Listas de la Comunidad (Slider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            // 6. Próximos Estrenos (Slider)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            movie['image']!,
                            fit: BoxFit.cover,
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
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Text(
                              movie['title']!,
                              style: TextStyle(
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
            // 7. Géneros Populares
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
