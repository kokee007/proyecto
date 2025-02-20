import 'package:flutter/material.dart';

class Draww extends StatelessWidget {
  final String? username;
  final String? email;

  const Draww({super.key, this.username, this.email});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado personalizado con datos del usuario
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/profile.jpg'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username ?? 'Usuario',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    child: Text(
                      email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Opciones del Drawer
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
                    Navigator.pushNamed(context, '/pagina2', arguments: username);
                  },
                ),
                _drawerItem(
                  icon: Icons.favorite,
                  text: 'Favoritos',
                  onTap: () {},
                ),
                _drawerItem(
                  icon: Icons.settings,
                  text: 'Configuración',
                  onTap: () {},
                ),
              ],
            ),
            // Botón de cierre de sesión
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navegar al login eliminando todas las rutas anteriores.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
