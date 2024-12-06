import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/constants/pick_image.dart';
import 'package:instagram_clone/controllers/auth_controller.dart';
import 'package:instagram_clone/controllers/post_controller.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:http/http.dart' as http;

import '../constants/colors.dart';
import '../utils/snack_bar.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  UserModel? user;
  File? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final postController = Get.put(PostController());
  final authController = Get.put(AuthController());

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  XFile file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = File(file.path);
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  XFile file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = File(file.path);
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> sendPostNotification() async {
    final userDoc = await firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(auth.currentUser!.uid)
        .get();

    var followers = userDoc.data()!['followers'];
    print(followers);
    final tokens = [];
    for (final followerId in followers) {
      final tokenDoc =
          await firestore.collection('tokens').doc(followerId).get();
      final token = tokenDoc.data()!['token'];

      tokens.add(token);
    }
    for (final userToken in tokens) {
      await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {
            "Authorization":
                "key=AAAADBEizMw:APA91bFVI_NnouSeqBNuigl8KXo4Sp_u7J2bjrOYQOqaeTQqYewCjxKv4AxMrYwfxKwG7U7Wznm0HJxmqWsPJ17zpeJqCccKBtcWzUEis22ktgP4mhpIHLu7V4fOl2eO5FGCp9juBodK",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "to": userToken,
            "priority": "high",
            "notification": {
              "title": "New Post",
              "body": "${user!.username} added a new post"
            },
            'data': {
              "android_channel_id": 'posts_channel',
            }
          }));
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    user = await authController.getUserData();
  }

  Future<void> postImage(String username, String profImage) async {
    setState(() {
      isLoading = true;
    });
    // start the loading
    try {
      // upload to storage and db
      postController
          .uploadPost(_descriptionController.text, username, profImage, _file)
          .then((value) {
        setState(() {
          isLoading = false;
        });

        showSnackBar(context, 'Posted');
        setState(() {
          _file = null;
        });
        sendPostNotification();
      });
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _file == null
        ? Center(
            child: IconButton(
              icon: const Icon(
                Icons.upload,
              ),
              onPressed: () => _selectImage(context),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: clearImage,
              ),
              title: const Text(
                'Post to',
              ),
              centerTitle: false,
              actions: <Widget>[
                TextButton(
                  onPressed: !isLoading
                      ? () => postImage(user!.username, user!.photoUrl)
                      : null,
                  child: const Text(
                    "Post",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                )
              ],
            ),
            // POST FORM
            body: Column(
              children: <Widget>[
                isLoading
                    ? const LinearProgressIndicator()
                    : const Padding(padding: EdgeInsets.only(top: 0.0)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        user!.photoUrl,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            hintText: "Write a caption...",
                            border: InputBorder.none),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45.0,
                      width: 45.0,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                            image: FileImage(_file!),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          );
  }
}
