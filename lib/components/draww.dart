// lib/components/draww.dart
import 'package:flutter/material.dart';

class Draww extends StatelessWidget {
  final String? username;
  final String? email;

  const Draww({Key? key, this.username, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor   = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade300,
                  bgColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.dividerColor,
                  child: Icon(Icons.person, color: theme.iconTheme.color, size: 40),
                ),
                const SizedBox(height: 10),
                Text(username ?? 'Usuario', style: theme.textTheme.titleLarge),
                if (email != null && email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(email!, style: theme.textTheme.titleMedium),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(context, Icons.home, 'Inicio', '/pagina1'),
                _drawerItem(context, Icons.movie, 'Películas', '/all_movies_page'),
                _drawerItem(context, Icons.category, 'Géneros', '/movies_by_genre_page'),
                _drawerItem(context, Icons.favorite, 'Favoritos', '/favoritos'),
                _drawerItem(context, Icons.newspaper, 'Noticias', '/noticias'),
                _drawerItem(context, Icons.settings, 'Configuración', '/configuracion'),
                const Divider(),
                _drawerItem(context, Icons.info, 'Acerca de', '/acerca_de'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
              icon: Icon(Icons.logout, color: theme.iconTheme.color),
              label: Text('Cerrar sesión', style: theme.textTheme.labelLarge),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String text, String route) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(text, style: theme.textTheme.bodyMedium),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route, arguments: username);
      },
    );
  }
}
