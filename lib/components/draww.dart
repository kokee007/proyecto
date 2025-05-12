// lib/components/draww.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Draww extends StatefulWidget {
  final String? username;
  final String? email;

  const Draww({Key? key, this.username, this.email}) : super(key: key);

  @override
  _DrawwState createState() => _DrawwState();
}

class _DrawwState extends State<Draww> {
  late final String _uid;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser!;
    _uid = user.uid;
    _userStream = FirebaseFirestore.instance
        .collection('usuaris')
        .doc(_uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final bgColor   = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _userStream,
            builder: (context, snap) {
              Widget avatar;
              if (snap.hasData && snap.data!.data() != null) {
                final data = snap.data!.data()!;
                final b64  = data['imgBase64'] as String?;
                final url  = data['imgUrl']    as String?;
                if (b64 != null && b64.isNotEmpty) {
                  final bytes = base64Decode(b64);
                  avatar = ClipOval(
                    child: Image.memory(
                      bytes,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(theme),
                    ),
                  );
                } else if (url != null && url.isNotEmpty) {
                  avatar = ClipOval(
                    child: Image.network(
                      url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(theme),
                    ),
                  );
                } else {
                  avatar = _placeholder(theme);
                }
              } else {
                avatar = _placeholder(theme);
              }

              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade300,
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
                      child: avatar,
                    ),
                    const SizedBox(height: 10),
                    Text(widget.username ?? 'Usuario',
                        style: theme.textTheme.titleLarge),
                    if (widget.email != null && widget.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(widget.email!, style: theme.textTheme.titleMedium),
                    ],
                  ],
                ),
              );
            },
          ),

          // Resto de items...
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

  /// Icono placeholder para el avatar
  Widget _placeholder(ThemeData theme) {
    return Icon(Icons.person, color: theme.iconTheme.color, size: 40);
  }

  Widget _drawerItem(BuildContext context, IconData icon, String text, String route) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(text, style: theme.textTheme.bodyMedium),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route, arguments: widget.username);
      },
    );
  }
}
