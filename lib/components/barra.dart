import 'package:flutter/material.dart';

class Barra extends StatelessWidget implements PreferredSizeWidget {
  final String title;             // Título dinámico (p.ej. "Home", "Movies", etc.)
  final String? username;         // Nombre de usuario (opcional)
  final VoidCallback? onSearchTap; // Acción al pulsar la lupa (opcional)

  const Barra({
    Key? key,
    required this.title,
    this.username,
    this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mapa de traducciones: si el título recibido es una clave, se mostrará su valor en español.
    final Map<String, String> titleTranslations = {
      "Home": "Inicio",
      "Movies": "Películas",
      "News": "Noticias",
      "Favorites": "Favoritos",
      "Genres": "Géneros",
      "Settings": "Configuración",
      "About": "Acerca de",
      "All Movies": "Todas las películas",
      "Movies by Genre": "Películas por género"
    };

    // Si existe una traducción para el título, se usará, de lo contrario se mostrará el título recibido.
    final String displayTitle = titleTranslations[title] ?? title;

    return Container(
      color: Colors.grey[700],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            backgroundColor: Colors.grey[700],
            elevation: 0,
            title: Row(
              children: [
                // Título dinámico traducido
                Expanded(
                  child: Text(
                    displayTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Botón de búsqueda
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: onSearchTap,
                ),
                // Muestra el nombre del usuario si está disponible
                if (username != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      username!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
          // Línea divisoria roja debajo de la AppBar
          Container(
            height: 2,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);
}
