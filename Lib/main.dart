import 'package:flutter/material.dart';

void main() => runApp(const PetPalApp());

const Color petGreen = Color(0xFF52796F);

class PetPalApp extends StatelessWidget {
  const PetPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetPal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: petGreen),
        scaffoldBackgroundColor: const Color(0xFFF8FAF9),
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const PetPalHome(),
    );
  }
}

// -------------------- MODELS --------------------

class Pet {
  String name, type, instructions;
  int age, count;

  Pet({
    required this.name,
    required this.type,
    required this.age,
    required this.count,
    required this.instructions,
  });
}

class Sitter {
  String name, petType, location, bio, experience, photo;
  double price, rating, distanceKm;
  List<String> acceptedPets;
  Set
