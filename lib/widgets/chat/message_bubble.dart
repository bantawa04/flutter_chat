import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String? message;
  final bool isMe;
  final String? userId;
  const MessageBubble(this.message, this.isMe, this.userId, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
                  !isMe ? const Radius.circular(0) : const Radius.circular(12),
              bottomRight:
                  isMe ? const Radius.circular(0) : const Radius.circular(12),
            ),
            color: isMe
                ? Colors.grey[300]
                : Theme.of(context).colorScheme.secondary,
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(userId)
                    .get(),
                builder: (ctx, snapShot) {
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }
                  Map<String, dynamic> data =
                      snapShot.data!.data() as Map<String, dynamic>;
                  return Text(
                    data["username"],
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isMe ? Colors.black : Colors.white),
                  );
                },
              ),
              Text(
                message!,
                style: TextStyle(
                    fontSize: 16, color: isMe ? Colors.black : Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
