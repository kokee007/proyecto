import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Box _boxUsuarios = Hive.box("box_usuarios");

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    String username = usernameController.text.trim();
    String password = passwordController.text;

    List usuarios = _boxUsuarios.get("usuarios") ?? [];
    bool autenticado = false;
    for (var usuario in usuarios) {
      if (usuario["username"] == username && usuario["password"] == password) {
        autenticado = true;
        break;
      }
    }

    if (autenticado) {
      // Navega a la pantalla principal y pasa el username como argumento
      Navigator.pushReplacementNamed(context, '/pagina1', arguments: username);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario o contraseña incorrectos")),
      );
    }
  }

  void irARegistro() {
    Navigator.pushNamed(context, '/registro');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Quitamos el AppBar para utilizar un fondo completo con degradado.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade400, Colors.blueAccent.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.movie,
                      size: 80,
                      color: Colors.teal.shade400,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: "Usuario",
                        prefixIcon: Icon(Icons.person, color: Colors.teal.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock, color: Colors.teal.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.teal.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Ingresar",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    TextButton(
                      onPressed: irARegistro,
                      child: Text(
                        "¿No tienes cuenta? Regístrate aquí",
                        style: TextStyle(color: Colors.teal.shade700),
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
