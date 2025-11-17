import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticateduser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }
        if (chatSnapshots.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }
        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatmessage =
                index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextChatmessage != null ? nextChatmessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticateduser.uid==currentMessageUserId,
              );
            }
            else{
              return MessageBubble.first(userImage: chatMessage['userImage'], username: chatMessage['userName'], message: chatMessage['text'], isMe: authenticateduser.uid==currentMessageUserId,);
            }
          },
        );
      },
    );
  }
}
