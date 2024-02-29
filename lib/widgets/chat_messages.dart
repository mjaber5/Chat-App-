import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LinearProgressIndicator(
              color: Theme.of(context).colorScheme.primaryContainer,
              backgroundColor: Colors.grey[300],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Somthing went wrong...'),
          );
        }

        final loadedMessage = snapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessage.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessage[index].data();
              final nextMessage = index + 1 < loadedMessage.length
                  ? loadedMessage[index + 1].data()
                  : null;

              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextMessage != null ? nextMessage['userId'] : null;
              final bool nextUserIsSame =
                  nextMessageUserId == currentMessageUserId;

              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authUser.uid == currentMessageUserId,
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMessage['userimage'],
                  username: chatMessage['userID'],
                  message: chatMessage['text'],
                  isMe: authUser.uid == currentMessageUserId,
                );
              }
            });
      },
    );
  }
}
