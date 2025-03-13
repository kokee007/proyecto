import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServeiAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getUsuariActual() {
    return _auth.currentUser;
  }

  // Cerrar sesión.
  Future<void> ferLogout() async {
    return await _auth.signOut();
  }

  // Login con email y password (método original, se conserva si lo requieres).
  Future<String?> loginAmbEmailIPassword(String email, String password) async {
    try {
      UserCredential credencialUsuari = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // Nuevo: Login con username y password.
  Future<String?> loginAmbUsernameIpassword(String username, String password) async {
    try {
      // Buscamos en Firestore el documento cuyo campo "nom" sea igual al username.
      QuerySnapshot querySnapshot = await _firestore
          .collection("usuaris")
          .where("nom", isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return "Usuario no encontrado";
      }

      // Suponemos que el username es único y tomamos el primer documento.
      var userDoc = querySnapshot.docs.first;
      String email = userDoc.get("email");

      // Iniciamos sesión con el email obtenido.
      UserCredential credencialUsuari = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return "Error: ${e.toString()}";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // Registro: recibe email, password y username.
  Future<String?> registreAmbEmailIPassword(String email, String password, String username) async {
    try {
      UserCredential credencialUsuari = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

       _firestore.collection("usuaris").doc(credencialUsuari.user!.uid).set({
        "email": email,
        "uid": credencialUsuari.user!.uid,
        "nom": username,
      });

      return null;
    } on FirebaseAuthException catch (e) {

      switch (e.code) {
        case "email-already-in-use":
          return "Ja hi ha un usuari amb aquest email.";
        case "invalid-email":
          return "Email no vàlid";
        case "operation-not-allowed":
          return "Email i/o contrasenya no habilitats";
        case "weak-password":
          return "Cal un password més robust";
        default:
          return "Error: ${e.toString()}";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}
