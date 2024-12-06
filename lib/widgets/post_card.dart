import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/screens/comment_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/snack_bar.dart';

import 'package:intl/intl.dart';

import '../constants/colors.dart';

class PostCard extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int commentLen = 0;
  bool isLikeAnimating = false;
  UserModel? user;
  final controller = Get.put(AuthController());
  final commentController = TextEditingController();
  final postController = Get.put(PostController());

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    user = await controller.getUserData();
    QuerySnapshot snapshot = await firestore
        .collection(FirestoreConstants.postsCollection)
        .doc(widget.snap['postId'])
        .collection(FirestoreConstants.commentCollection)
        .get();
    commentLen = snapshot.docs.length;
    setState(() {});
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to delete the post?'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => postController
                                .deletePost(widget.snap['postId'], context)
                                .then((value) {
                             Navigator.pop(context);
                              showSnackBar(context, 'Post deleted');
                            }),
                        child: const Text(
                          'Delete Post',
                          style: TextStyle(color: Colors.red),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final width = MediaQuery.of(context).size.width;

    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: mobileBackgroundColor,
        ),
        color: mobileBackgroundColor,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () =>
                      Get.to(() => ProfileScreen(uid: widget.snap['uid'])),
                  child: CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          CachedNetworkImageProvider(widget.snap['profImage'])),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(children: [
                  widget.snap['uid'] == auth.currentUser!.uid
                      ? IconButton(
                          onPressed: _showDialog,
                          icon: const Icon(Icons.more_vert))
                      : Container(),
                ])
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.snap['postUrl'].toString(),
                    placeholder: (context, url) {
                      return const Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ));
                    },
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  postController.likePost(widget.snap['postId'].toString(),
                      auth.currentUser!.uid, widget.snap['likes']);
                },
                icon: Icon(
                  widget.snap['likes'].contains(auth.currentUser!.uid)
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  color: widget.snap['likes'].contains(auth.currentUser!.uid)
                      ? Colors.red
                      : null,
                  size: 30,
                ),
              ),
              IconButton(
                  icon: SvgPicture.asset(
                    'assets/comment.svg',

                    // ignore: deprecated_member_use
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Get.to(() => CommentScreen(
                          postId: widget.snap['postId'].toString(),
                          collection: FirestoreConstants.postsCollection,
                          uid: widget.snap['uid'],
                        ));
                  }),
              Transform.rotate(
                angle: 5.8,
                child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      size: 30,
                    ),
                    onPressed: () {}),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    icon: const Icon(Icons.bookmark_border), onPressed: () {}),
              ))
            ],
          ),
          //DESCRIPTION AND NUMBER OF COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: primaryColor),
                      children: [
                        TextSpan(
                          text: widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.snap['description']}',
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'View all $commentLen comments',
                        style: const TextStyle(
                          fontSize: 16,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                    onTap: () {}),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.snap['datePublished'].toDate()),
                    style: const TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
