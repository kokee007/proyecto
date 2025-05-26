import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/auth/login_o_registre.dart';
import 'package:proyecto/pagines/login.dart';
import 'package:proyecto/pagines/pagina1.dart';

class PortalAuth extends StatelessWidget {
  const PortalAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){

          if (snapshot.hasData){
            return const Pagina1();
          } else {
            return LoginORegistre();
          }
        },
      ),
    );
  }
}
