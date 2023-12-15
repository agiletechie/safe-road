import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:road_safety/data/data.dart';

class AuthNotifier with ChangeNotifier {
  AuthNotifier({required data}) : _data = data;
  final Data _data;
  User? _user;
  bool _hasException = false;
  bool _isLoading = false;
  String? _displayName;
  String? _errorMessage;

  User? get user => _user;
  bool get hasException => _hasException;
  bool get isLoading => _isLoading;
  String? get displayName => _displayName;
  String? get errorMessage => _errorMessage;

  void createNewUser(String email, String password) async {
    _errorMessage = null;
    _hasException = false;
    try {
      _isLoading = true;
      notifyListeners();
      _user = await _data.createUser(email, password);
    } catch (e) {
      _hasException = true;
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void signInUser(String email, String password) async {
    _errorMessage = null;
    _hasException = false;
    try {
      _isLoading = true;
      notifyListeners();
      _user = await _data.signinUser(email, password);
    } catch (e) {
      _hasException = true;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void fetchUser() {
    _user = _data.fetchUser();
  }

  void logout() async {
    await _data.logoutUser();
    _user = null;
    _displayName = null;
    _isLoading = false;
    _hasException = false;
    notifyListeners();
  }

  Future<void> updateUserNameAndWriteToDoc(String name) async {
    _hasException = false;
    _errorMessage = null;
    try {
      _displayName = name;
      _isLoading = true;
      notifyListeners();
      _user = await _data.updateUserName(name);
      if (_user != null) {
        await _data.writeUserToDoc(_user!);
      }
    } catch (e) {
      //just to be safe here
      _displayName = null;
      _hasException = true;
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
