import 'package:flutter/material.dart';

class Draww extends StatelessWidget {
  final String? username;
  final String? email;

  const Draww({super.key, this.username, this.email});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Fondo general negro para el Drawer
      backgroundColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado con degradado de gris oscuro a negro
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.black87],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar del usuario
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade700,
                  backgroundImage: const AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(height: 10),
                // Nombre del usuario
                Text(
                  username ?? 'Usuario',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Email (si está disponible)
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Opciones del Drawer
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  icon: Icons.home,
                  text: 'Inicio',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/pagina1', arguments: username);
                  },
                ),
                _drawerItem(
                  icon: Icons.movie,
                  text: 'Películas',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/all_movies_page', arguments: username);
                  },
                ),
                _drawerItem(
                  icon: Icons.category,
                  text: 'Géneros',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/movies_by_genre_page', arguments: username);
                  },
                ),
                _drawerItem(
                  icon: Icons.favorite,
                  text: 'Favoritos',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/favoritos', arguments: username);
                  },
                ),
                _drawerItem(
                  icon: Icons.settings,
                  text: 'Configuración',
                  onTap: () {
                    // Acción a pantalla de configuración
                  },
                ),
                const Divider(
                  color: Colors.white54,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                _drawerItem(
                  icon: Icons.info,
                  text: 'Acerca de',
                  onTap: () {
                    // Acción a pantalla "Acerca de"
                  },
                ),
              ],
            ),
          ),
          // Botón "Cerrar sesión"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para crear cada ítem del Drawer
  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}
