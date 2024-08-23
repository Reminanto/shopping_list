import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  carbs,
  other,
  meat,
  dairy,
  sweets,
  spices,
  hygiene,
  convenience,
}

class Category {
  const Category(this.title,this.color );
  final String title;
  final Color color;
}
