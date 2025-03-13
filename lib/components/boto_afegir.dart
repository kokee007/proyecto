import 'package:flutter/material.dart';

class BotoAfegir extends StatelessWidget {
  final String textBoto;
  final Function()? accioboto;

  const BotoAfegir({Key? key, required this.textBoto, required this.accioboto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: accioboto,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      child: Text(
        textBoto,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
