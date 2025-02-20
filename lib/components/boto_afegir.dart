import 'package:flutter/material.dart';

class BotoAfegir extends StatelessWidget {

  final String textBoto;
  final Function()? accioboto;

  const BotoAfegir({super.key, required this.textBoto, required this.accioboto});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: accioboto,
      color: Colors.red,
      child: Text(textBoto),
      );
  }
}