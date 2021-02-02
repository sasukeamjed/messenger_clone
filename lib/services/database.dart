import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethods{
  Future addUserInfoToDB(String userId, Map<String, dynamic> userInfoMap) async{
    return FirebaseFirestore.instance.collection("users").doc(userId).set(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getUserbyUsername(String username) async{
    return FirebaseFirestore.instance.collection('users').where("username", isEqualTo: username).snapshots();
  }

  Future addMessage(String chatRoomId, String messageId, Map messageInfoMap) async{
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).collection("chats").doc(messageId).set(messageInfoMap);
  }
}