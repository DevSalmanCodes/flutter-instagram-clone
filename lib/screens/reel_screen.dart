import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/controllers/reel_controll.dart';
import 'package:instagram_clone/controllers/user_controlller.dart';
import 'package:instagram_clone/screens/comment_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/widgets/video_item.dart';

class ReelScreen extends StatefulWidget {
  const ReelScreen({super.key});

  @override
  State<ReelScreen> createState() => _ReelScreenState();
}

class _ReelScreenState extends State<ReelScreen> {
  final reelController = Get.put(ReelController());
  final userController = Get.put(UserController());
  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Obx(
        () => PageView.builder(
          itemCount: reelController.reelList.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            final data = reelController.reelList[index];
            return Stack(
              children: [
                VideoItem(videoUrl: data.videoUrl.toString()),
                Column(
                  children: [
                    const SizedBox(
                      height: 100,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Add avatar here
                                      GestureDetector(
                                        onTap: () => Get.to(
                                            () => ProfileScreen(uid: data.uid)),
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundImage: NetworkImage(
                                              data.profilePhoto.toString()),
                                        ),
                                      ),
                                      // Add text here

                                      GestureDetector(
                                        onTap: () => Get.to(
                                            () => ProfileScreen(uid: data.uid)),
                                        child: Text(
                                          data.username.toString(),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      // Add text button here
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          side: const BorderSide(
                                              color: Colors.white, width: 1.5),
                                        ),
                                        child: const Text(
                                          'Follow',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          userController.followUser(
                                              auth.currentUser!.uid,
                                              data.uid,
                                              context);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  Text(
                                    data.caption,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.music_note,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      Expanded(
                                        child: Text(
                                          data.songName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 100,
                              margin: EdgeInsets.only(
                                top: size.height / 3,
                                right: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  //  here
                                  _buildColumn(
                                      onTap: () {
                                        reelController.likeReel(
                                            data.id.toString(),
                                            auth.currentUser!.uid,
                                            context);
                                      },
                                      icon: Icon(
                                        data.likes
                                                .contains(auth.currentUser!.uid)
                                            ? Icons.favorite
                                            : Icons.favorite_outline,
                                        color: data.likes
                                                .contains(auth.currentUser!.uid)
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                      title: data.likes.length.toString()),
                                  _buildColumn(
                                    icon: SvgPicture.asset(
                                      'assets/comment.svg',
                                      // ignore: deprecated_member_use
                                      color: Colors.white,
                                    ),
                                    title: data.commentCount.toString(),
                                    onTap: () => Get.to(() => CommentScreen(
                                          postId: data.id,
                                          collection:
                                              FirestoreConstants.reelCollection,
                                          uid: data.uid,
                                        )),
                                  ),
                                  _buildColumn(
                                      icon: const Icon(Icons.share),
                                      title: data.shareCount.toString()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // New row just above the username row at the bottom
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildColumn(
      {required Widget icon,
      required String title,
      Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          GestureDetector(onTap: onTap, child: icon),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
