import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class CategoryModel {
  final String name;
  final IconData icon;

  CategoryModel({required this.name, required this.icon});

  factory CategoryModel.fromMap(DocumentSnapshot doc) {
    return CategoryModel(name: doc['name'], icon: doc['icon']);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon};
  }
}
