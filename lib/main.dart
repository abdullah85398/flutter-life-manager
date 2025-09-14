import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app/app.dart';

void main() {
  // Simplified main without Firebase for now
  runApp(
    const ProviderScope(
      child: LifeManagerApp(),
    ),
  );
}