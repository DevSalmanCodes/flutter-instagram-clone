import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/methods/storage_method.dart';
import 'package:uuid/uuid.dart';

import '../constants/firebase_consts.dart';
import '../constants/firestore_consts.dart';
import '../models/post.dart';

class PostController extends GetxController {
  Future<void> uploadPost(description, username, profImage, file) async {
    String photoUrl = await uploadImageToStorage('posts', file, true);
    String postId = const Uuid().v1();
    Post post = Post(
        description: description,
        uid: auth.currentUser!.uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage);
    await firestore
        .collection(FirestoreConstants.postsCollection)
        .doc(postId)
        .set(post.toJson());
  }

  Stream<QuerySnapshot> getPosts() {
    return firestore
        .collection(FirestoreConstants.postsCollection)
        .orderBy('datePublished', descending: true)
        .snapshots();
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await firestore
            .collection(FirestoreConstants.postsCollection)
            .doc(postId)
            .update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await firestore
            .collection(FirestoreConstants.postsCollection)
            .doc(postId)
            .update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(postId, BuildContext context) async {
    firestore
        .collection(FirestoreConstants.postsCollection)
        .doc(postId)
        .delete();
  }

  likeComment(postId, commentId, List likes, uid, collection) async {
    try {
      if (likes.contains(uid)) {
        await firestore
            .collection(collection)
            .doc(postId)
            .collection(FirestoreConstants.commentCollection)
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await firestore
            .collection(collection)
            .doc(postId)
            .collection(FirestoreConstants.commentCollection)
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e);
    }
  }

  deleteComment(postId, commentId, collection,) async {
    try {
      await firestore
          .collection(collection)
          .doc(postId)
          .collection(FirestoreConstants.commentCollection)
          .doc(commentId)
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
