import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post{
  final String description;
  final String postId;
  final datePublished;
  final String postUrl;
  final String user;
  final int like;
  final double latitude;
  final double longitude;

  const Post({
    required this.description,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.user,
    required this.like,
    required this.latitude,
    required this.longitude,
});

  Map<String, dynamic> toJson() =>{
    "description": description,
    "postId": postId,
    "datePublished": datePublished,
    "postUrl" : postUrl,
    "user": user,
    "like" : like,
    "likeUser" : FieldValue.arrayUnion([]),
    "latitude" : latitude,
    "longitude" : longitude,
  };

}