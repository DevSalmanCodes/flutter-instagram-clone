import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/controllers/upload_reel_controller.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/utils/snack_bar.dart';
import 'package:video_player/video_player.dart';

import '../constants/colors.dart';
import '../controllers/auth_controller.dart';

class UploadReelScreen extends StatefulWidget {
  const UploadReelScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UploadReelScreenState createState() => _UploadReelScreenState();
}

class _UploadReelScreenState extends State<UploadReelScreen> {
  late VideoPlayerController videoPlayerController;
  final _songController = TextEditingController();
  final _captionController = TextEditingController();
  final uploadReelController = Get.put(UploadReelController());
  final authController = Get.put(AuthController());
  UserModel? user;
  File? _file;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getData();
    setState(() {
      videoPlayerController =
          VideoPlayerController.file(File(_file.toString()));
    });
    videoPlayerController.initialize();
    videoPlayerController.setVolume(1);
    videoPlayerController.setLooping(true);
    videoPlayerController.play();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> pickVideo(ImageSource source) async {
    var pickedVideo = await ImagePicker().pickVideo(source: source);
    if (pickedVideo != null) {
      setState(() {
        _file = File(pickedVideo.path);
      });
    }
  }

  _uploadReel() async {
    setState(() {
      isLoading = true;
    });
    uploadReelController
        .uploadReel(_file, _captionController.text, _songController.text,
            user!.username, user!.photoUrl)
        .then((value) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, 'Reel Uploaded');
      Get.back();
    });
  }

  getData() async {
    user = await authController.getUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _file == null
          ? Center(
              child: GestureDetector(
                onTap: () {
                  pickVideo(ImageSource.gallery);
                },
                child: const Icon(Icons.upload),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: VideoPlayer(videoPlayerController),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width - 20,
                          child: TextField(
                            controller: _songController,
                            decoration: InputDecoration(
                              labelText: 'Song Name',
                              prefixIcon: const Icon(Icons.music_note),
                              labelStyle: const TextStyle(
                                fontSize: 20,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.of(context).size.width - 20,
                          child: TextField(
                            controller: _captionController,
                            decoration: InputDecoration(
                              labelText: 'Caption',
                              prefixIcon: const Icon(Icons.closed_caption),
                              labelStyle: const TextStyle(
                                fontSize: 20,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 20,
                          child:   InkWell(
                onTap: _uploadReel,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    color: blueColor,
                  ),
                  child: !isLoading
                      ? const Text(
                          'Post',
                      )
                      : const CircularProgressIndicator(
                          color: primaryColor,
                          strokeWidth: 2.5,
                        ),
                ),
              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
