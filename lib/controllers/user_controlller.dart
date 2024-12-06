import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/utils/snack_bar.dart';

class UserController extends GetxController {


  followUser(uid, followId,BuildContext context) async {
    try {
      DocumentSnapshot snapshot =
          await firestore.collection(FirestoreConstants.usersCollection).doc(uid).get();
      List following = (snapshot.data()! as dynamic)['following'];
      if (following.contains(followId)) {
        await firestore.collection(FirestoreConstants.usersCollection).doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await firestore.collection(FirestoreConstants.usersCollection).doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await firestore.collection(FirestoreConstants.usersCollection).doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await firestore.collection(FirestoreConstants.usersCollection).doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

 
}
