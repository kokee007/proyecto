import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isDarkTheme = false;
  bool _isSaving = false;

  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('usuaris').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['nom'] ?? '';
        _nicknameController.text = data['apodo'] ?? '';
        _isDarkTheme = data['darkTheme'] ?? false;
        _currentImageUrl = data['profileImageUrl'];
        _imageUrlController.text = _currentImageUrl ?? '';
        setState(() {});
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('usuaris').doc(user.uid).update({
        'nom': _nameController.text.trim(),
        'apodo': _nicknameController.text.trim(),
        'darkTheme': _isDarkTheme,
        'profileImageUrl': _imageUrlController.text.trim(),
      });
      setState(() {
        _currentImageUrl = _imageUrlController.text.trim();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    final TextEditingController _passwordController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Cambiar contraseña', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _passwordController,
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = _auth.currentUser;
                if (user != null && _passwordController.text.isNotEmpty) {
                  await user.updatePassword(_passwordController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña actualizada')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrangeAccent),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.grey[850],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[700],
              backgroundImage: _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                  ? NetworkImage(_currentImageUrl!)
                  : null,
              child: _currentImageUrl == null || _currentImageUrl!.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.white54)
                  : null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                hintText: 'URL Imagen de perfil',
                prefixIcon: const Icon(Icons.link, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                prefixIcon: const Icon(Icons.person, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Apodo',
                prefixIcon: const Icon(Icons.tag, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Modo oscuro', style: TextStyle(color: Colors.white)),
              value: _isDarkTheme,
              onChanged: (v) => setState(() => _isDarkTheme = v),
              activeColor: Colors.redAccent,
              tileColor: Colors.grey[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Guardar cambios', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _changePassword,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cambiar contraseña', style: TextStyle(color: Colors.blueAccent, fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _logout,
              child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
