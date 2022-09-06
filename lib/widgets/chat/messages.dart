import 'dart:developer';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  Future<String?> _getUserData() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserData(),
      builder: (ctx, futuresnapShot) {
        if (futuresnapShot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chat")
              .orderBy(
                "created_at",
                descending: true,
              )
              .snapshots(),
          builder: (ctx, chatSnapShot) {
            if (chatSnapShot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final document = chatSnapShot.data!.docs;
            return ListView.builder(
              reverse: true,
              itemBuilder: (ctx, index) => Container(
                padding: const EdgeInsets.all(8),
                child: MessageBubble(
                  document[index]['text'],
                  document[index]["userId"] == futuresnapShot.data,
                  document[index]['username'],
                  key: ValueKey(document[index].id),
                ),
              ),
              itemCount: document.length,
            );
          },
        );
      },
    );
  }
}
