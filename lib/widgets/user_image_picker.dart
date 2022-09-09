import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;

  const UserImagePicker(this.imagePickFn,{Key? key}) : super(key: key);
  
  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  void _imagePicker(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    final XFile? imageFile = await picker.pickImage(
      source: source,
    );

    setState(() {
      _pickedImage = File(imageFile!.path);
    });
    
    widget.imagePickFn(File(imageFile!.path));

    Navigator.pop(context);
  }

  void _pickImageModel(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return Container(
            height: 100.0,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            child: Column(
              children: <Widget>[
                TextButton.icon(
                  icon: const Icon(Icons.camera),
                  onPressed: () => _imagePicker(ImageSource.camera),
                  label: const Text("Camera"),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.image),
                  onPressed: () => _imagePicker(ImageSource.gallery),
                  label: const Text("Gallery"),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueGrey,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
          onPressed: () => _pickImageModel(context),
          icon: const Icon(Icons.image),
          label: const Text("Add Image"),
        )
      ],
    );
  }
}
