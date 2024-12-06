import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:uuid/uuid.dart';

import '../models/reel.dart';
import '../utils/snack_bar.dart';

class ReelController extends GetxController {
  final Rx<List<Reel>> _reelList = Rx<List<Reel>>([]);


  List<Reel> get reelList => _reelList.value;
  @override
  void onInit() {
    _reelList.bindStream(firestore
        .collection(FirestoreConstants.reelCollection)
        .snapshots()
        .map((reel) {
      List<Reel> reels = [];
      for (final i in reel.docs) {
        reels.add(Reel.fromSnap(i));
      }
      return reels;
    }));
    super.onInit();
  }

  likeReel(
    id,
    uid,
    BuildContext context,
  ) async {
    try {
      final reelDocs = await firestore
          .collection(FirestoreConstants.reelCollection)
          .doc(id)
          .get();
      List likes = reelDocs.data()!['likes'];
      if (likes.contains(uid)) {
        firestore.collection(FirestoreConstants.reelCollection).doc(id).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        firestore.collection(FirestoreConstants.reelCollection).doc(id).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  commentReel(
      comment, username, profImage, uid, BuildContext context, reelId) async {
    final id = Uuid().v1();

    try {
      await firestore
          .collection(FirestoreConstants.reelCollection)
          .doc(reelId)
          .collection(FirestoreConstants.commentCollection)
          .doc(id)
          .set({
        'comment': comment,
        'userName': username,
        'userProfImage': profImage,
        'uid': uid,
        'commentId': id,
        'datePublished': Timestamp.now(),
        'likes': [],
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
  }

  fetchReelComments(reelId) {
    try {
      return firestore
          .collection(FirestoreConstants.reelCollection)
          .doc(reelId)
          .collection(FirestoreConstants.commentCollection)
          .snapshots();
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }
}
