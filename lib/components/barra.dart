import 'package:flutter/material.dart';

class Barra extends StatelessWidget implements PreferredSizeWidget {
  final String title;             // Título dinámico (p.ej. "Inicio", "Noticias", etc.)
  final String? username;         // Nombre de usuario (opcional)
  final VoidCallback? onSearchTap; // Acción al pulsar la lupa (opcional)

  const Barra({
    super.key,
    required this.title,
    this.username,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
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
                // Título dinámico
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Ícono de búsqueda
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: onSearchTap,
                ),
                // Nombre de usuario (si existe)
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
