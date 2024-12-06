import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/methods/storage_method.dart';
import 'package:instagram_clone/models/reel.dart';
import 'package:uuid/uuid.dart';

import '../constants/firebase_consts.dart';

class UploadReelController extends GetxController {
  // _compressVideo(videoPath) async {
  //   final compressedVideo = await VideoCompress.compressVideo(videoPath.toString(),
  //       quality: VideoQuality.MediumQuality);
  //  if(compressedVideo!=null){
  //    return compressedVideo.file;
  //  }
  // }

  // getThumbnail(videoPath) async {
  //   final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
  //   return thumbnail;
  // }

  Future<void> uploadReel(video, caption, songName, username, profImage) async {
    Reference ref = storage.ref().child('reels').child(Uuid().v1());
    // final compressedVideo =await _compressVideo(video.toString());

    UploadTask task = ref.putFile(video);
    TaskSnapshot taskSnapshot = await task;
    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    // final thumbnail =await getThumbnail(video.toString());

    final uid = auth.currentUser!.uid;
    final id = const Uuid().v1();
    Reel reel = Reel(
        username: username,
        uid: uid,
        id: id,
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: downloadUrl,
        profilePhoto: profImage,
        thumbnail: '');

    await firestore.collection(FirestoreConstants.reelCollection).doc(id).set(reel.toJson());
  }

  uploadThumbnail(file) async {
    final thumbUrl = uploadImageToStorage('thumbnails', file, false);
    return thumbUrl;
  }
}
