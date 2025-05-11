// lib/pagines/configuracion.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto/main.dart'; // para themeNotifier

/// ------------------------------------------------------------------
/// 1) FONDO ANIMADO DE TUERCAS (⚙️) – sin cambios
/// ------------------------------------------------------------------
class Gear {
  final Offset position;
  final double size;
  final double rotation;
  final double twinkleOffset;
  Gear({
    required this.position,
    required this.size,
    required this.rotation,
    required this.twinkleOffset,
  });
}

class GearFieldPainter extends CustomPainter {
  final List<Gear> gears;
  final double animationValue;
  GearFieldPainter({required this.gears, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final gear in gears) {
      final opacity = 0.5 + 0.5 * sin(animationValue + gear.twinkleOffset);
      tp.text = TextSpan(
        text: '⚙️',
        style: TextStyle(
            fontSize: gear.size, color: Colors.grey.withOpacity(opacity)),
      );
      tp.layout();
      final dx = gear.position.dx * size.width;
      final dy = gear.position.dy * size.height;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(animationValue + gear.rotation);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant GearFieldPainter old) =>
      old.animationValue != animationValue;
}

class AnimatedGearBackground extends StatefulWidget {
  const AnimatedGearBackground({Key? key}) : super(key: key);
  @override
  _AnimatedGearBackgroundState createState() => _AnimatedGearBackgroundState();
}

class _AnimatedGearBackgroundState extends State<AnimatedGearBackground>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  late final List<Gear> _gears;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _gears = List.generate(60, (_) {
      return Gear(
        position: Offset(rnd.nextDouble(), rnd.nextDouble()),
        size: rnd.nextDouble() * 24 + 16,
        rotation: rnd.nextDouble() * 2 * pi,
        twinkleOffset: rnd.nextDouble() * 2 * pi,
      );
    });
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 2 * pi).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return CustomPaint(
          size: Size.infinite,
          painter: GearFieldPainter(gears: _gears, animationValue: _anim.value),
        );
      },
    );
  }
}

/// ------------------------------------------------------------------
/// 2) PÁGINA DE CONFIGURACIÓN
/// ------------------------------------------------------------------
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
  final _urlCtrl = TextEditingController();
  bool _isDark = false;
  bool _saving = false;

  XFile? _pickedImage;
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
    _nameCtrl.text = data['nom'] ?? '';
    _nickCtrl.text = data['apodo'] ?? '';
    _isDark = data['darkTheme'] ?? false;
    themeNotifier.value = _isDark ? ThemeMode.dark : ThemeMode.light;
    _base64Image = data['imgBase64'];
    _urlImage = data['imgUrl'];
    _urlCtrl.text = _urlImage ?? '';
    setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        maxHeight: 600,
      );
      if (picked == null) return;
      _pickedImage = picked;
      _urlCtrl.clear();
      final bytes = await picked.readAsBytes();
      _base64Image = base64Encode(bytes);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final user = _auth.currentUser;
    if (user == null) return;
    final upd = {
      'nom': _nameCtrl.text.trim(),
      'apodo': _nickCtrl.text.trim(),
      'darkTheme': _isDark,
      'imgBase64': _base64Image,
      'imgUrl': _urlCtrl.text.trim(),
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
        title: const Text('Cambiar contraseña',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Nueva contraseña',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54)),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.white))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent),
            onPressed: () async {
              try {
                await _auth.currentUser?.updatePassword(ctrl.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña actualizada')));
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
    final bodyColor = Theme.of(context).textTheme.bodyMedium?.color;
    ImageProvider? avatar;
    if (_pickedImage != null) {
      avatar = FileImage(File(_pickedImage!.path));
    } else if (_base64Image?.isNotEmpty == true) {
      avatar = MemoryImage(base64Decode(_base64Image!));
    } else if (_urlCtrl.text.isNotEmpty) {
      avatar = NetworkImage(_urlCtrl.text);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGearBackground()),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).dividerColor,
                    backgroundImage: avatar,
                    child: avatar == null
                        ? Icon(Icons.person,
                            size: 60, color: Theme.of(context).hintColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Toca la imagen para cambiarla',
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    hintText: 'URL Imagen (opcional)',
                    prefixIcon: Icon(Icons.link,
                        color: Theme.of(context).iconTheme.color),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  style: TextStyle(color: bodyColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person,
                        color: Theme.of(context).iconTheme.color),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  style: TextStyle(color: bodyColor),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nickCtrl,
                  decoration: InputDecoration(
                    labelText: 'Apodo',
                    prefixIcon: Icon(Icons.tag,
                        color: Theme.of(context).iconTheme.color),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  style: TextStyle(color: bodyColor),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title:
                      Text('Modo oscuro', style: TextStyle(color: bodyColor)),
                  value: _isDark,
                  onChanged: (v) {
                    setState(() => _isDark = v);
                    themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                  },
                  activeColor: Colors.redAccent,
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.secondary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cambiar contraseña',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _auth.signOut().then(
                      (_) => Navigator.pushReplacementNamed(context, '/login')),
                  child:
                      Text('Cerrar sesión', style: TextStyle(color: bodyColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}