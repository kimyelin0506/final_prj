import 'dart:typed_data';

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../model/post.dart';



class ImageStoreMethods{

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //storage에 업로드
  Future<String> imageToStorage(Uint8List file) async{
    String id = const Uuid().v1();  //post의 id
    Reference ref = _storage.ref().child('testImg').child(id);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  //firestore에 업로드
  Future<String> uploadPost(String description, Uint8List file,String user) async{
    String res = 'some Error occured';
    try{
      String photoUrl = await imageToStorage(file);
      String postId = const Uuid().v1();
      Post post = Post(
        description: description,
        postId: postId,
        datePublished : DateTime.now(),
        postUrl : photoUrl,
        user: user,
      );
      
      _firestore.collection('uploadImgTest').doc(postId).set(post.toJson());
      res = 'success';
    }catch(e){
      res = e.toString();
    }
    return res;
  }
}