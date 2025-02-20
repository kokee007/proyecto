import 'package:flutter/material.dart';

class Barra extends StatelessWidget implements PreferredSizeWidget {
  final String? username; // Nombre del usuario, opcional

  const Barra({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[700],
      title: Row(
        children: [
          const Text(
            "FILM REVIEWER",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 30),
          // Campo de búsqueda
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[600],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          // Si ya hay un usuario logueado, se muestra su nombre
          if (username != null)
            Text(
              username!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            )
          else ...[
            // Si no hay usuario, se muestran los botones de Iniciar sesión y Registrarse
            TextButton(
              onPressed: () {
                // Acción de iniciar sesión (por ejemplo, navegar a la pantalla de login)
              },
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {
                // Acción de registrarse (por ejemplo, navegar a la pantalla de registro)
              },
              child: const Text(
                'Registrarse',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
