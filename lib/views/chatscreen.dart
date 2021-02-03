import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messenger_clone/helperfunctions/sharedpref_helper.dart';
import 'package:messenger_clone/services/database.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithUsername, name;

  const ChatScreen({Key key, this.chatWithUsername, this.name})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String chatRoomId, messageId = "";
  String myName, myProfilePic, myUserName, myEmail;
  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPrefs() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfilePic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername, myUserName);
  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  addMessage(bool sendClicked){
    if(messageTextEditingController.text != ""){
      String message = messageTextEditingController.text;

      var lastMessageTimestamp = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message" : message,
        "sendBy" : myUserName,
        "ts" : lastMessageTimestamp,
        "imageUrl" : myProfilePic
      };

      //Message Id
      if(messageId == ""){
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods().addMessage(chatRoomId, messageId, messageInfoMap).then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lastMessage" : message,
          "lastMessageSentTS" : lastMessageTimestamp,
          "lastMessageSendBy" : myUserName,
        };

        DatabaseMethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);

        if(sendClicked){
          messageTextEditingController.text = "";
          messageId = "";

        }
      });
    }
  }

  getAndSetMessages() async {}

  doThisOnLaunch() async {
    getMyInfoFromSharedPrefs();
    getAndSetMessages();
  }

  @override
  void initState() {
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageTextEditingController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "type a message",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.send, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
