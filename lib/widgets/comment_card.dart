// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/snack_bar.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap;
  final String collection;
  final String postId;
  const CommentCard(
      {Key? key,
      required this.snap,
      required this.postId,
      required this.collection})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final postController = Get.put(PostController());
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Comment?'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () {
                postController.deleteComment(
                  widget.postId,
                  widget.snap['commentId'],
                  widget.collection,
              
                );

                Navigator.of(context).pop(); // Close the dialog
                showSnackBar(context, 'Comment deleted');
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.to(() => ProfileScreen(uid: widget.snap['uid'])),
            child: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.snap['userProfImage']),
              radius: 18,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onLongPress: () {
                  if (widget.snap['uid'] == auth.currentUser!.uid) {
                    _showDeleteDialog();
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: widget.snap['userName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          TextSpan(
                            text: ' ${widget.snap['comment']}',
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat.yMMMd().format(
                          widget.snap['datePublished'].toDate(),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(0),
                child: IconButton(
                  onPressed: () {
                    postController.likeComment(
                        widget.postId,
                        widget.snap['commentId'].toString(),
                        widget.snap['likes'],
                        auth.currentUser!.uid,
                        widget.collection);
                  },
                  icon: Icon(
                    widget.snap['likes'].contains(auth.currentUser!.uid)
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    size: 22,
                    color: widget.snap['likes'].contains(auth.currentUser!.uid)
                        ? Colors.red
                        : null,
                  ),
                ),
              ),
              Text(widget.snap['likes'].length.toString())
            ],
          )
        ],
      ),
    );
  }
}
