import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthAPI {
  late FirebaseAuth auth;
  late FirebaseFirestore database;

  FirebaseAuthAPI() {
    auth = FirebaseAuth.instance;
    database = FirebaseFirestore.instance;
  }

  Stream<User?> fetchUser() {
    return auth.authStateChanges();
  }

  User? getUser() {
    return auth.currentUser;
  }

  Future<void> deleteAccount() async {
    try {
      await auth.currentUser?.delete();
      print("Deleted Account");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
            'The user must reauthenticate before this operation can be executed.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String?> signUp(
      String name,
      String userName,
      String email,
      String password,
      String contactNo,
      String profilePicture,
      String userType,
      Map<String, String> addresses,
      bool isOrg) async {
    try {
      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
      }
      await database.runTransaction(
        (Transaction transaction) async {
          DocumentReference donorViewref =
              database.collection("users").doc(userCredential.user!.uid);

          // check is user exists
          DocumentSnapshot snapshot = await transaction.get(donorViewref);
          if (!snapshot.exists) {
            // Add user info to Firestore
            // print("here");
            transaction.set(
              donorViewref,
              {
                'name': name,
                'user_name': userName,
                'email': email,
                'contact_no': contactNo,
                'addresses': addresses,
                'is_org': isOrg,
                'id': userCredential.user!.uid,
                'profile_picture': profilePicture,
                'user_type': userType,
                'org_id': '',
              },
            );
          }
        },
      );

      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      if (e.code == 'weak-password') {
        return 'weak-password';
      } else if (e.code == 'email-already-in-use') {
        return 'email-already-in-use';
      } else {
        return 'Firebase Error: ${e.message}';
      }
    } on FirebaseException catch (e) {
      // Handle other Firebase exceptions
      return 'Firebase Error: ${e.message}';
    } catch (e) {
      // Handle other exceptions
      return 'Error: ${e.toString()}';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      // UserCredential credentials =
      await auth.signInWithEmailAndPassword(email: email, password: password);
      // print(credentials);
      return "Success";
    } on FirebaseException catch (e) {
      return (e.code);
      // if (e.code == 'user-not-found') {
      //   return ('No user found for that email.');
      // } else if (e.code == 'wrong-password') {
      //   return ('Wrong password provided for that user.');
      // }
    } catch (e) {
      return ('Firebase Error: $e');
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
