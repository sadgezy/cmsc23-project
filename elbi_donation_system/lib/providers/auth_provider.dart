import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api/firebase_auth_api.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> _userStream;

  Stream<User?> get userStream => _userStream;
  User? get user => authService.getUser();

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    fetchUser();
  }

  void fetchUser() {
    _userStream = authService.fetchUser();
  }

  String getUserInitials() {
    final displayName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((l) => l[0]).take(2).join()
        : '';
    return initials;
  }

  String getUserDisplayName() {
    return FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  Future<void> signOut() async {
    await authService.signOut();
    notifyListeners();
  }

  Future<void> signUp(
    String name,
    String userName,
    String email,
    String password,
    String contactNo,
    String profilePic,
    String userType,
    Map<String, String> addresses,
    bool isOrg,
  ) async {
    await authService.signUp(name, userName, email, password, contactNo, profilePic,
        userType, addresses, isOrg);
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    await authService.signIn(email, password);
    notifyListeners();
  }
}
