import 'package:flutter/material.dart';
import 'package:flutter_frontend/map_screen.dart';

void main() {
  runApp(MaterialApp(initialRoute: '/', routes: {
    '/': (context) => MapScreen(),
  }));
}
