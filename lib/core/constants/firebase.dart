import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final fireStore = FirebaseFirestore.instance;
final user = FirebaseAuth.instance.currentUser;
String? userId;
DocumentReference<Map<String, dynamic>> get userCollection =>
    fireStore.collection('users').doc(userId);

CollectionReference<Map<String, dynamic>> get transactionsCollection =>
    fireStore.collection('users').doc(userId).collection('expenses');
final fireAuth = FirebaseAuth.instance;