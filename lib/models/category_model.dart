import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final int colorValue;

  CategoryModel({
    required this.name,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'name': name,
        'colorValue': colorValue,
      };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        name: json['name'],
        colorValue: json['colorValue'],
      );
}
