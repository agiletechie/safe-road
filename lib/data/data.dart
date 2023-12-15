import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:road_safety/data/models/report.dart';

class Data {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance.ref();
  final _auth = FirebaseAuth.instance;

  User? fetchUser() {
    final user = _auth.currentUser;
    return user;
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  Future<User?> createUser(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // credential.user?.updateDisplayName(displayName);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception(e);
      } else if (e.code == 'email-already-in-use') {
        throw Exception(e);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<User?> updateUserName(String name) async {
    if (_auth.currentUser == null) return null;

    await _auth.currentUser!.updateDisplayName(name);
    return _auth.currentUser;
  }

  Future<void> writeUserToDoc(User user) async {
    await _db
        .collection('users')
        .add({'userName': user.displayName, 'email': user.email});
  }

  Future<User?> signinUser(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception(e);
      } else if (e.code == 'wrong-password') {
        throw Exception(e);
      }
    }
    return null;
  }

  Future<List<Report>> getReports() async {
    final QuerySnapshot<Map<String, dynamic>> reports =
        await _db.collection('reports').get();

    final List<Report> docs = reports.docs.map((doc) {
      final Map<String, dynamic> reportData = doc.data();
      debugPrint(reportData.toString());
      return Report.fromJson(reportData);
    }).toList();

    return docs;
  }

  Future<String> uploadImage(XFile image) async {
    final ref = _storage.child('images/${image.name}');
    UploadTask task = ref.putFile(
        File(image.path), SettableMetadata(contentType: 'image/jpeg'));
    await task;

    String link = await task.snapshot.ref.getDownloadURL();
    return link;
  }

  Future<String> writeReport(XFile image, Report report) async {
    String link = '';
    try {
      link = await uploadImage(image);
    } catch (e) {
      throw Exception('Error in file upload');
    }

    report.imageUrl = link;
    final DocumentReference<Map<String, dynamic>> doc =
        await _db.collection('reports').add(report.toJson());

    return doc.id;
  }
}
