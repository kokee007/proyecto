import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final Box _boxUsuarios = Hive.box("box_usuarios");

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void register() {
    String username = usernameController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    List usuarios = _boxUsuarios.get("usuarios") ?? [];
    bool existe = usuarios.any((usuario) => usuario["username"] == username);
    if (existe) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El usuario ya existe")),
      );
      return;
    }

    usuarios.add({"username": username, "password": password});
    _boxUsuarios.put("usuarios", usuarios);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registro exitoso, por favor inicia sesión")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con degradado oscuro (negro a gris oscuro)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              // Tarjeta con fondo gris oscuro
              color: Colors.grey.shade900,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título en rojo para resaltar
                    Text(
                      "Registro",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Icono en azul para dar contraste
                    Icon(
                      Icons.person_add,
                      size: 80,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 24),
                    // Campo de texto para el usuario
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Usuario",
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        fillColor: Colors.grey.shade800,
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo de texto para la contraseña
                    TextField(
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        fillColor: Colors.grey.shade800,
                        filled: true,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    // Campo para confirmar la contraseña
                    TextField(
                      controller: confirmPasswordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Confirmar Contraseña",
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.blueAccent),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        fillColor: Colors.grey.shade800,
                        filled: true,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    // Botón de registro con fondo rojo
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
