import 'package:flutter/material.dart';
import 'package:proyecto/pagines/login.dart';
import 'package:proyecto/pagines/registro.dart';

class LoginORegistre extends StatefulWidget {
  const LoginORegistre({super.key});

  @override
  State<LoginORegistre> createState() => _LoginORegistreState();
}

class _LoginORegistreState extends State<LoginORegistre> {

  bool mostraPaginaLogin = true;

  void intercanviarPaginesLoginRegistre() {
    setState(() {
      mostraPaginaLogin = !mostraPaginaLogin;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(mostraPaginaLogin){
      return LoginPage(ferClic: intercanviarPaginesLoginRegistre,);
    }else {
      return RegistroPage(ferClic: intercanviarPaginesLoginRegistre,);
    }
    
  }
}