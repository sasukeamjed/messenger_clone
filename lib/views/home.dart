import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messenger_clone/helperfunctions/sharedpref_helper.dart';
import 'package:messenger_clone/services/auth.dart';
import 'package:messenger_clone/services/database.dart';
import 'package:messenger_clone/views/chatscreen.dart';
import 'package:messenger_clone/views/signin.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  TextEditingController _searchUsernameController = TextEditingController();
  String myName, myProfilePic, myUserName, myEmail;

  getMyInfoFromSharedPrefs() async {
    myName = await SharedPreferenceHelper().getDisplayName();
    myProfilePic = await SharedPreferenceHelper().getUserProfilePic();
    myUserName = await SharedPreferenceHelper().getUserName();
    myEmail = await SharedPreferenceHelper().getUserEmail();

  }

  getChatRoomIdByUsernames(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  Stream usersStream;

  _onSearchBtnClick() async {
    setState(() {
      isSearching = true;
    });
    usersStream = await DatabaseMethods()
        .getUserbyUsername(_searchUsernameController.text);
  }

  Widget searchListUserTile(String profileUrl, String name, String username,String email) {
    return GestureDetector(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              profileUrl,
              height: 30,
              width: 30,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              Text(email),
            ],
          ),
        ],
      ),
      onTap: (){
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String, dynamic> chatRoomInfoMap = {
          "users" : [myUserName, username],

        };
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ChatScreen(chatWithUsername: username, name: name,);
        }));
      },
    );
  }


  @override
  void initState() {
    getMyInfoFromSharedPrefs();
    super.initState();
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      ds['imgUrl'], ds['name'], ds['username'],ds['email']);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget chatRoomsList() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((_) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return SignIn();
                }));
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.exit_to_app),
            ),
          ),
        ],
        title: Text("Messenger Clone"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.arrow_back),
                        ),
                        onTap: () {
                          setState(() {
                            isSearching = false;
                            _searchUsernameController.text = "";
                          });
                        },
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "username"),
                            controller: _searchUsernameController,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.search),
                          onTap: () {
                            if (_searchUsernameController.text.isNotEmpty) {
                              _onSearchBtnClick();
                              setState(() {
                                isSearching = true;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : chatRoomsList(),
          ],
        ),
      ),
    );
  }
}
