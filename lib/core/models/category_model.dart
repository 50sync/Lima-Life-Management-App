import 'package:flutter/widgets.dart';

class CategoryModel {
  final String name;
  final IconData icon;

  CategoryModel({required this.name, required this.icon});

  factory CategoryModel.fromMap(Map<String,dynamic> json) {
    return CategoryModel(name: json['name'], icon: json['icon']);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon};
  }
}
