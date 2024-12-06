import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/user_controlller.dart';
import 'package:instagram_clone/utils/snack_bar.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

import '../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ignore: prefer_typing_uninitialized_variables
  var userData;

  int postLen = 0;
  bool isLoading = false;
  final userController = Get.put(UserController());
  final authController = Get.put(AuthController());
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      userData =
          await firestore.collection(FirestoreConstants.usersCollection).doc(widget.uid).get();

      QuerySnapshot postSnap = await firestore
          .collection(FirestoreConstants.postsCollection)
          .where('uid', isEqualTo: widget.uid)
          .get();
      postLen = postSnap.docs.length;
      setState(() {});
    } catch (e) {
      // ignore: use_build_context_synchronously
      showSnackBar(context, e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      StreamBuilder(
                        stream: firestore
                            .collection(FirestoreConstants.usersCollection)
                            .doc(widget.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final data = snapshot.data!.data();
                            var isFollowing = data!['followers']
                                .contains(auth.currentUser!.uid);
                            var followers = data['followers'].length;
                            var following = data['following'].length;
                            return Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  backgroundImage: CachedNetworkImageProvider(
                                    data['photoUrl'],
                                  ),
                                  radius: 40,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          buildStatColumn(postLen, "posts"),
                                          buildStatColumn(
                                              followers, "followers"),
                                          buildStatColumn(
                                              following, "following"),
                                        ],
                                      ),
                                      // ignore: prefer_const_constructors
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          widget.uid == auth.currentUser!.uid
                                              ? FollowButton(
                                                  function: () {
                                                    authController
                                                        .userLogOut(context);
                                                  },
                                                  backgroundColor:
                                                      mobileBackgroundColor,
                                                  borderColor: Colors.grey,
                                                  text: 'Sign Out',
                                                  textColor: primaryColor)
                                              : isFollowing
                                                  ? FollowButton(
                                                      function: () async {
                                                        await userController
                                                            .followUser(
                                                                auth.currentUser!
                                                                    .uid,
                                                                data['uid'],
                                                                context);
                                                      },
                                                      backgroundColor:
                                                          Colors.white,
                                                      borderColor: Colors.grey,
                                                      text: 'Unfollow',
                                                      textColor: Colors.black)
                                                  : FollowButton(
                                                      function: () async {
                                                        await userController
                                                            .followUser(
                                                                auth.currentUser!
                                                                    .uid,
                                                                data['uid'],
                                                                context);
                                                      },
                                                      backgroundColor:
                                                          Colors.blue,
                                                      borderColor: Colors.blue,
                                                      text: 'Follow',
                                                      textColor: Colors.white)
                                          //  Follow button here
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            );
                          }
                        },
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                FutureBuilder(
                  future: firestore
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5,),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        var snap = (snapshot.data! as dynamic).docs[index];
                        return SizedBox(
                            child: CachedNetworkImage(
                          imageUrl: snap['postUrl'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) {
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            );
                          },
                        ));
                      },
                    );
                  },
                ),
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
