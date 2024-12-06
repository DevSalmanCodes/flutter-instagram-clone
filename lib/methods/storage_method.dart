import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../constants/firebase_consts.dart';

Future<String> uploadImageToStorage(
    String childName, File file, bool isPost) async {

  Reference ref = storage.ref().child(childName).child(auth.currentUser!.uid);
  if (isPost) {
    String id = const Uuid().v1();
    ref = ref.child(id);
  }

  UploadTask uploadTask = ref.putFile(file);

  TaskSnapshot snapshot = await uploadTask;
  String downloadUrl = await snapshot.ref.getDownloadURL();
  return downloadUrl;
}


