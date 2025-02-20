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
      // Usamos un fondo con degradado para el registro también.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.shade200, Colors.teal.shade400],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Registro",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.person_add,
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: "Confirmar Contraseña",
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: register,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.teal.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(fontSize: 18),
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
