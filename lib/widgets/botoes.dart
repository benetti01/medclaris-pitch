import 'package:flutter/material.dart';

Widget botao(String texto, VoidCallback funcao) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(onPressed: funcao, child: Text(texto)),
  );
}
