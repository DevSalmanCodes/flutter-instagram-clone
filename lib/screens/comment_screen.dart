import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/utils/snack_bar.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class CommentScreen extends StatefulWidget {
  const CommentScreen(
      {super.key, required this.postId, required this.collection, this.uid});
  final String postId;
  final String collection;
  final String? uid;
  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  UserModel? user;
  final _authController = Get.put(AuthController());
  final _commentController = TextEditingController();
  @override
  void initState() {
    getData();
    super.initState();
  }

  uploadPost() async {
    if (_commentController.text.isNotEmpty) {
      final id = const Uuid().v1();
      await firestore
          .collection(widget.collection)
          .doc(widget.postId)
          .collection(FirestoreConstants.commentCollection)
          .doc(id)
          .set({
        'userName': user!.username,
        'userProfImage': user!.photoUrl,
        'uid': user!.uid,
        'comment': _commentController.text,
        'likes': [],
        'commentId': id,
        'datePublished': Timestamp.now()
      }).then((value) {
        _commentController.clear();
        widget.uid != auth.currentUser!.uid
            ? _sendNotification(widget.uid, user!.username)
            : null;
      });
    } else {
      showSnackBar(context, 'Comment cannot be empty! ');
    }
  }

  void getData() async {
    user = await _authController.getUserData();
    setState(() {});
  }

  Future<void> _sendNotification(uid, user) async {
    var doc = await firestore.collection('tokens').doc(uid).get();
    final token = doc.data()!["token"];
    await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: {
          "Authorization":
              "key=AAAADBEizMw:APA91bFVI_NnouSeqBNuigl8KXo4Sp_u7J2bjrOYQOqaeTQqYewCjxKv4AxMrYwfxKwG7U7Wznm0HJxmqWsPJ17zpeJqCccKBtcWzUEis22ktgP4mhpIHLu7V4fOl2eO5FGCp9juBodK",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "to": token,
          "priority": "high",
          "notification": {
            "title": "New Comment",
            "body": "$user Commented on your post"
          },
          'data': {
            'postId': widget.postId,
            "android_channel_id": 'comments_channel',
            'collection': widget.collection,
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream: firestore
              .collection(widget.collection)
              .doc(widget.postId)
              .collection(FirestoreConstants.commentCollection)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return CommentCard(
                    snap: snapshot.data!.docs[index].data(),
                    postId: widget.postId,
                    collection: widget.collection,
                  );
                },
              );
            }
          },
        ),
        bottomNavigationBar: SafeArea(
            child: Container(
                height: kToolbarHeight,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Row(children: [
                  CircleAvatar(
                      backgroundImage: user != null
                          ? NetworkImage(
                              user!.photoUrl,
                            )
                          : const NetworkImage(
                              'https://i.stack.imgur.com/l60Hf.png')),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                  ),
                  Expanded(
                      child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                        hintText: 'Add a comment', border: InputBorder.none),
                  )),
                  TextButton(
                      onPressed: () => uploadPost(), child: const Text('Post'))
                ]))));
  }
}
