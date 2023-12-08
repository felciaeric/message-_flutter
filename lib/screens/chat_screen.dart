import 'package:flutter/material.dart';
import 'package:message_flutter/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
late User loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();

  late String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality

                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          MessagesStream(),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {

                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
    stream: _firestore.collection('messages').snapshots(),
  builder: ( context, AsyncSnapshot snapshot) {
  if (!snapshot.hasData) {
  return Center(
  child: CircularProgressIndicator(
  backgroundColor: Colors.lightBlueAccent,
  ));
  }
  final messages = snapshot.data.docs.reversed.toList();
  List<MessageBubble> messageBubbles = [];
  for (var message in messages) {
  final messageText = message.data()['text'];
  final messageSender = message.data()['sender'];
  final user = loggedInUser.email;

  final messageBubble = MessageBubble(text: messageText,sender: messageSender,isMe: user == messageSender,);

  messageBubbles.add(messageBubble);
  }
  return Expanded(child: ListView(
    reverse: true,
  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
  children: messageBubbles));
  });
  }
}


class MessageBubble extends StatelessWidget {
  MessageBubble({ required this.text, required this.sender,required this.isMe});
   final String text;
  final String sender;
  final  bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender,style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),),
          Material(
            borderRadius: isMe? BorderRadius.only(topLeft: Radius.circular(30),bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30),) : BorderRadius.only(bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30),topRight: Radius.circular(30)),
            elevation: 5,
            color:isMe? Colors.lightBlueAccent: Colors.white,
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: Text(text,style: TextStyle(
                color: isMe ? Colors.red : Colors.black54,
                fontSize: 15
                    ),),
            ),),
        ],
      ),
    );
  }
}
