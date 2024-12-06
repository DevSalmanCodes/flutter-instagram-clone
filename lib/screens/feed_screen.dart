import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/screens/upload_reel_screen.dart';
import 'package:instagram_clone/services/notifications/notification_services.dart';

import '../constants/colors.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  NotificationServices notificationServices = NotificationServices();

  final authController = Get.put(AuthController());
  final postController = Get.put(PostController());

  @override
  void initState() {
    notificationServices.initilize();
    storeToken();
    super.initState();
  }
    storeToken()async{
     await notificationServices.getToken().then((value)async{
     await firestore.collection('tokens').doc(auth.currentUser!.uid).set({
      'token':value,
     });
      });

    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          centerTitle: false,
          title: SvgPicture.asset(
            'assets/ic_instagram.svg',
            // ignore: deprecated_member_use
            color: Colors.white,
            height: 32,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => Get.to(() => const UploadReelScreen()),
                child: SvgPicture.asset(
                  'assets/reel.svg',
                  // ignore: deprecated_member_use
                  color: Colors.white,
                  width: 35,
                ),
              ),
            )
          ],
        ),
        body: StreamBuilder(
          stream: postController.getPosts(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    return PostCard(
                      snap: snapshot.data!.docs[index].data(),
                    );
                  });
            }
          },
        ));
  }
}
