import 'package:flutter/material.dart';

Widget titulo(String texto) {
  return Text(
    texto,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  );
}

Widget texto(String texto) {
  return Text(texto, style: const TextStyle(fontSize: 16));
}