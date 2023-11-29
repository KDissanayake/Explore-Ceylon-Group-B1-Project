import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({required this.name, required this.icon, required this.color});
}

List<Category> categories = [
  Category(name: 'Veggies', icon: Icons.local_florist, color: Colors.green),
  Category(name: 'Fruit', icon: Icons.favorite, color: Colors.red),
  Category(name: 'Dry Rations', icon: Icons.shopping_cart, color: Colors.blue),
  // Add more categories as needed
];
