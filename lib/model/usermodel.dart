import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String name;
  final String email;
  final String facat;
  //final Uint8List file;

  const UserModel({
    required this.name,
    required this.email,
    required this.facat,
    /*required this.file*/});


    factory UserModel.fromMap(Map<String, dynamic>map){
      return UserModel(
          name: map["userName"],
          email: map["email"],
        facat: map["facat"],
        //file: map["profilepic"],
      );
    }
  }

