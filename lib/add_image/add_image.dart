import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddImage extends StatefulWidget {
  final Function(File pickedImage) addImageFunc;
  const AddImage({required this.addImageFunc, super.key});

  @override
  State<AddImage> createState() => _AddImageState();
}

class _AddImageState extends State<AddImage> {
  XFile? pickedImage;


  void _pickImage() async {
    //임시 저장을 위해 XFIle로 저장
    final imagePicker = ImagePicker();
    final pickedImageFile =
        await imagePicker.pickImage(source: ImageSource.camera,
        imageQuality: 50,
        maxHeight: 150,
        );
    setState(() {
      if(pickedImageFile != null) {
        pickedImage = File(pickedImageFile!.path) as XFile?;
      }
    });
    widget.addImageFunc(pickedImage! as File);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      width: 150,
      height: 300,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            backgroundImage: pickedImage != null ? FileImage(pickedImage as File)
            : null,
          ),
          SizedBox(
            height: 10,
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.image),
            label: Text('Add Icon'),
          ),
          SizedBox(
            height: 80,
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close),
            label: Text('close'),
          ),
        ],
      ),
    );
  }
}
