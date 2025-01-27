// ignore_for_file: equal_keys_in_map, unnecessary_string_escapes, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:messenger/helper/helper_function.dart';
import 'package:messenger/service/notifications.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection("chats");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("meets");

  // // saving the userdata
  // Future savingUserData(String fullName, String email) async {
  //   return await userCollection.doc(uid).set({
  //     "fullName": fullName,
  //     "email": email,
  //     "chats": [],
  //     "profilePic": "",
  //     "uid": uid,
  //     "age":"",
  //     "about":""
  //   });
  // }
  Future savingUserDataAfterRegister(
      String fullName,
      String email,
      int age,
      String rost,
      String city,
      bool deti,
      String hobbi,
      String about,
      String pol) async {
    FirebaseAuth.instance.currentUser!.updateDisplayName(fullName);
    FirebaseAuth.instance.currentUser!.updateEmail(email);
    return await userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "fullName": fullName,
      "email": email,
      "chats": [],
      "profilePic": "",
      "uid": uid,
      "age": age,
      "rost": rost,
      "about": about,
      "hobbi": hobbi,
      "deti": deti,
      "temperament": "",
      "uid": FirebaseAuth.instance.currentUser!.uid,
      "city": city,
      "images": [],
      "pol": pol,
    });
  }

  Future updateUserData(String fullName, String email, int age, String about,
      String hobbi, String city) async {
    return await userCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      "fullName": fullName,
      "email": email,
      "age": age,
      "about": about,
      "hobbi": hobbi,
      "city": city
    });
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // // creating a group
  // Future createChat(String MyUserName,String userName) async {
  //   DocumentReference groupDocumentReference = await chatCollection.doc(SomebodyProfile().getChatRoomIdByUsernames(MyUserName, userName)).get().add({
  //     "userNames": [MyUserName, userName],
  //     "chatId": SomebodyProfile().getChatRoomIdByUsernames(MyUserName, userName),
  //     "messages":[],
  //     "lastMessage":[]
  //   });
  //   // update the members
  //   // await groupDocumentReference.update({
  //   //   "members": FieldValue.arrayUnion(["${uid}_$userName"]),
  //   //   "groupId": groupDocumentReference.id,
  //   // });
  //   //
  //   // DocumentReference userDocumentReference = userCollection.doc(uid);
  //   // return await userDocumentReference.update({
  //   //   "groups":
  //   //       FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
  //   // });
  // }

  // getting the chats
  getChats(String chatId) async {
    return chatCollection
        .doc(chatId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  // search
  searchByName(String userName) {
    return chatCollection.where("users[1]", isEqualTo: userName).get();
  }

  //function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String chatId, Map<String, dynamic> chatMessageData) async {
    chatCollection.doc(chatId).collection("messages").add(chatMessageData);
    chatCollection.doc(chatId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  sendMessageGroup(String chatId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(chatId).collection("messages").add(chatMessageData);
    groupCollection.doc(chatId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });

    var usersDoc = await groupCollection.doc(chatId).get();

    var users = usersDoc.get('users');

    for (int i = 0; i < users.length; i++) {
      if (users[i] != FirebaseAuth.instance.currentUser!.uid) {
        var doc = await FirebaseFirestore.instance
            .collection('TOKENS')
            .doc(users[i])
            .get();

        var snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(users[i])
            .get();

        String token = doc.get('token');
        String name = snap.get('fullName');

        NotificationsService().sendPushMessage(
            token,
            chatMessageData['message'],
            name,
            1,
            FirebaseAuth.instance.currentUser!.photoURL,
            chatId);
      }
    }
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .snapshots();
  }

  createChatRoom(String chatRoomId, var chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .get();

    if (snapShot.exists) {
      // chatroom already exists
      return true;
    } else {
      // chatroom does not exists
      return FirebaseFirestore.instance
          .collection("chats")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<QuerySnapshot> getUserInfo(String username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get();
  }

  getChatRoomIdByUserID(String a, String b) {
    if (a.isNotEmpty && b.isNotEmpty) {
      if (a.substring(0, 1).codeUnitAt(0) <= b.substring(0, 1).codeUnitAt(0)) {
        return "$a\_$b";
      } else {
        return "$b\_$a";
      }
    } else {
      return "abrakadabra";
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("ts", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getGroupMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("meets")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('time', descending: false)
        .snapshots();
  }

  Future<String> GetChatRoomId(String user1, String user2) async {
    String chatId = "";
    await FirebaseFirestore.instance
        .collection("chats")
        .where("chatId", isEqualTo: getChatRoomIdByUserID(user1, user2))
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isEmpty) {
        chatId = getChatRoomIdByUserID(user2, user1);
      } else {
        chatId = getChatRoomIdByUserID(user1, user2);
      }
    });
    return chatId;
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String myUsername = HelperFunctions().getUserName().toString();
    return FirebaseFirestore.instance
        .collection("chats")
        //.orderBy("lastMessage", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }

  Future addMessage(String chatRoomId, String messageId, messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(String chatRoomId, lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chats")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  updateUnreadMessageCount(String chatRoomId) async {
    DocumentSnapshot count = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .get();
    int kolvo = count.get('unreadMessage') + 1;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .update({"unreadMessage": kolvo});
  }

  Future addChat(String uid, String chatId) {
    return FirebaseFirestore.instance.collection("users").doc(uid).update({
      "chats": FieldValue.arrayUnion([chatId])
    });
  }

  Future addChatSecondUser(String uid, String chatId) {
    return FirebaseFirestore.instance.collection("users").doc(uid).update({
      "chats": FieldValue.arrayUnion([chatId])
    });
  }
}
