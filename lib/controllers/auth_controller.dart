// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/methods/storage_method.dart';

import '../constants/firebase_consts.dart';
import '../models/user.dart';
import '../screens/home.dart';
import '../screens/login_screen.dart';
import '../utils/snack_bar.dart';

class AuthController extends GetxController {
  Future<void> createUser({
    required username,
    required email,
    required password,
    required photoUrl,
    required bio,
    required BuildContext context,
  }) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = auth.currentUser!.uid.toString();
      String photo = await uploadImageToStorage('profilePics', photoUrl, false);
      UserModel newUser = UserModel(
          username: username,
          uid: uid,
          photoUrl: photo,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          password: password);
      await firestore
          .collection('users')
          .doc(uid)
          .set(newUser.toJson())
          .then((value) {
        Get.offAll(() => const Home());
        showSnackBar(context, 'Account created');
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showSnackBar(context, 'Email already in use');
      } else if (e.code == 'invalid-email') {
        showSnackBar(context, 'Invalid email');
      } else if (e.code == 'weak-password') {
        showSnackBar(context, 'Weak password');
      } else {
        if (kDebugMode) {
          print(e.toString());
        }
      }
    }
  }

  Future<void> loginUser(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await auth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        Get.offAll(() => const Home());
        showSnackBar(context, 'Account Logged in succesfully');
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        showSnackBar(context, 'Invalid email');
      } else if (e.code == 'user-disabled') {
        showSnackBar(context, 'User disabled');
      } else if (e.code == 'user-not-found') {
        showSnackBar(context, 'User not found');
      } else if (e.code == 'wrong-password') {
        showSnackBar(context, 'Wrong password');
      } else {
        if (kDebugMode) {
          showSnackBar(context, e.toString());
        }
      }
    }
  }

  Future<void> setData(username, email, password, photoUrl, bio) async {}

  userLogOut(BuildContext context) async {
    await auth.signOut();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
  }

  Future<UserModel?> getUserData() async {
    DocumentSnapshot snapshot = await firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(auth.currentUser!.uid)
        .get();
    if (snapshot.exists) {
      return UserModel.fromSnap(snapshot);
    } else {
      return null;
    }
  }
}
