import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  // Future<UploadTask?> uploadFile(File? file, String uid) async {
  //   UploadTask uploadTask;

  //   // Create a Reference to the file
  //   Reference ref =
  //       FirebaseStorage.instance.ref().child('user_images').child('$uid.jpg');

  //   final metadata = SettableMetadata(
  //     contentType: 'image/jpeg',
  //     customMetadata: {'picked-file-path': file!.path},
  //   );

  //   uploadTask = ref.putFile(File(file.path), metadata);

  //   uploadTask.whenComplete(() async {
  //     final url = await ref.getDownloadURL();
  //     inspect(url);
  //     return Future.value(url);
  //   });
  //   return null;
  // }

  void _submitAuthForm(String email, String username, String password,
      bool isLogin, BuildContext ctx, File pickedImage) async {
    try {
      setState(() {
        _isLoading = true;
      });
      UserCredential authResult;
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        UploadTask uploadTask;

        // Create a Reference to the file
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${authResult.user!.uid}.jpg');

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': pickedImage.path},
        );

        uploadTask = ref.putFile(File(pickedImage.path), metadata);

        uploadTask.whenComplete(() async {
          final url = await ref.getDownloadURL();
          inspect(url);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(authResult.user!.uid)
              .set({
            "username": username,
            "email": email,
            "image_url": url,
          });
        });

        setState(() {
          _isLoading = false;
        });
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isLoading = false;
      });
      var message = "An error occured, please check your credentials !";

      if (error.message != null) {
        message = error.message!;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
