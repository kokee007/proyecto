import 'package:flutter/material.dart';
import 'package:proyecto/auth/servei_auth.dart';
import 'package:proyecto/auth/servei_auth.dart'; // Asegúrate de que la ruta de importación sea correcta

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Instancia del servicio de Firebase
  final ServeiAuth _serveiAuth = ServeiAuth();

  void login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    // Se intenta iniciar sesión usando el username y contraseña (Firebase)
    String? error = await _serveiAuth.loginAmbUsernameIpassword(username, password);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // Si se inicia sesión correctamente, se navega a la siguiente pantalla
    Navigator.pushReplacementNamed(context, '/pagina1', arguments: username);
  }

  void irARegistro() {
    Navigator.pushNamed(context, '/registro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo con degradado oscuro
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
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Icono temático de películas en azul
                    Icon(
                      Icons.movie,
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
                    const SizedBox(height: 24),
                    // Botón de ingreso con fondo rojo
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Ingresar",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    // Opción para registrarse
                    TextButton(
                      onPressed: irARegistro,
                      child: Text(
                        "¿No tienes cuenta? Regístrate aquí",
                        style: TextStyle(color: Colors.redAccent),
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
