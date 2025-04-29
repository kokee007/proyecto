import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importamos el fondo de corazones que ya existe en favoritos.dart
import 'package:proyecto/pagines/favoritos.dart' show AnimatedHeartBackground;

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({Key? key}) : super(key: key);
  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  final _nameCtrl = TextEditingController();
  final _nickCtrl = TextEditingController();
  final _urlCtrl  = TextEditingController();
  bool _isDark = false;
  bool _saving = false;

  String? _base64Image;
  String? _urlImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('usuaris').doc(user.uid).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    _nameCtrl.text  = data['nom'] ?? '';
    _nickCtrl.text  = data['apodo'] ?? '';
    _isDark         = data['darkTheme'] ?? false;
    _base64Image    = data['imgBase64'];
    _urlImage       = data['imgUrl'];
    _urlCtrl.text   = _urlImage ?? '';
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _base64Image = base64Encode(bytes);
      _urlCtrl.clear();
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final user = _auth.currentUser;
    if (user == null) return;
    final upd = {
      'nom':       _nameCtrl.text.trim(),
      'apodo':     _nickCtrl.text.trim(),
      'darkTheme': _isDark,
      'imgBase64': _base64Image,
      'imgUrl':    _urlCtrl.text.trim(),
    };
    try {
      await _firestore.collection('usuaris').doc(user.uid).update(upd);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cambiar contraseña', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Nueva contraseña',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white54),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
            onPressed: () async {
              try {
                await _auth.currentUser?.updatePassword(ctrl.text.trim());
                ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Contraseña actualizada')));
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatar;
    if (_base64Image != null) {
      avatar = MemoryImage(base64Decode(_base64Image!));
    } else if (_urlCtrl.text.isNotEmpty) {
      avatar = NetworkImage(_urlCtrl.text);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Aquí reutilizamos el fondo animado de corazones
          const Positioned.fill(child: AnimatedHeartBackground()),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[700],
                    backgroundImage: avatar,
                    child: avatar == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white54)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Toca la imagen para cambiarla',
                    style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    hintText: 'URL Imagen (opcional)',
                    prefixIcon: const Icon(Icons.link, color: Colors.white70),
                    filled: true, fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    filled: true, fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nickCtrl,
                  decoration: InputDecoration(
                    labelText: 'Apodo',
                    prefixIcon: const Icon(Icons.tag, color: Colors.white70),
                    filled: true, fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Modo oscuro', style: TextStyle(color: Colors.white)),
                  value: _isDark,
                  onChanged: (v) => setState(() => _isDark = v),
                  activeColor: Colors.redAccent,
                  tileColor: Colors.grey[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar cambios',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _changePassword,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: Colors.blueAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cambiar contraseña',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _auth
                      .signOut()
                      .then((_) => Navigator.pushReplacementNamed(context, '/login')),
                  child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
