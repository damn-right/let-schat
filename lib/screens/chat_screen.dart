import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flash_chat/components/MessageBubble.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';


FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  ChatScreen({this.roomName, this.roomId});
  static const String id = 'chat_screen';
  final String roomId;
  final String roomName;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  List<MessageBubble> messageBubbles = [];
  String messageText;
  List<Asset> images = [];
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  //TODO: Image product holder
  Widget imageGridView() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return Padding(
          padding: EdgeInsets.all(5),
          child: Stack(
            children: <Widget>[
              //TODO: image
              AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
              ),
              //TODO: close
              GestureDetector(
                onTap: () {
                  setState(() {
                    images.removeAt(index);
                  });
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.close, color: Colors.black, size: 18)),
              )
            ],
          ),
        );
      }),
    );
  }

  //TODO Save Image to Firebase 6
  Future saveImage(List<Asset> asset) async {
    StorageUploadTask uploadTask;
    List<String> linkImage = [];
    for (var value in asset) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
      ByteData byteData = await value.getByteData(quality: 70);
      var imageData = byteData.buffer.asUint8List();
      uploadTask = ref.putData(imageData);
      String imageUrl;
      await (await uploadTask.onComplete).ref.getDownloadURL().then((onValue) {
        imageUrl = onValue;
      });
      linkImage.add(imageUrl);
    }
    return linkImage;
  }

  //TODO: load multi image
  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#000000",
          actionBarTitle: "Pick Product Image",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      images = resultList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E2945),
        leading: null,
        title: Text(widget.roomName),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
        Image.asset
          (
          "images/spc.gif",
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
           ),
      SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  //TODO: Chat space
                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('messages')
                        .orderBy('timestamp')
                        .where('roomId', isEqualTo: widget.roomId)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        final messages = snapshot.data.documents.reversed;
                        List<MessageBubble> messageBubbles = [];
                        for (var message in messages) {
                          final messageText = message.data['text'];
                          final messageSender = message.data['sender'];
                          final List<dynamic> images = message.data['image'];
                          final currentUser = loggedInUser.email;
                          final messageBubble = MessageBubble(
                            sender: messageSender,
                            text: (messageText != null) ? messageText : '',
                            isMe: currentUser == messageSender,
                            context: context,
                            imagesList:
                            (images != null || images.length != 0) ? images : [],
                            onDeletemessage: () {
                              Firestore.instance
                                  .collection('messages')
                                  .document(message.documentID)
                                  .delete();
                              setState(() {});
                            },
                          );

                          messageBubbles.add(messageBubble);
                        }
                        return Expanded(
                          child: ListView(
                            reverse: true,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 20.0),
                            children: messageBubbles,
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  //TODO: Image holder
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: (images.length != 0) ? imageGridView() : Container(),
                  ),

                  Container(
                    decoration: kMessageContainerDecoration,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            loadAssets();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.image,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                        ),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            controller: messageTextController,
                            onChanged: (value) {
                              messageText = value;
                            },
                            decoration: kMessageTextFieldDecoration.copyWith(hintStyle: TextStyle(color:Colors.white)),
                          ),
                        ),
                        //TODO: sent image
                        TextButton(
                          onPressed: () async {
                            if (images.length != 0) {
                              List<String> listImages = await saveImage(images);
                              messageTextController.clear();
                              setState(() {
                                images.clear();
                              });
                              Firestore.instance.collection('messages').add({
                                'roomId': widget.roomId,
                                'text': messageTextController.text,
                                'sender': loggedInUser.email,
                                'image': listImages,
                                'timestamp':
                                DateTime.now().toUtc().millisecondsSinceEpoch
                              });
                            } else if (messageTextController.text != null &&
                                messageTextController.text != '') {
                              Firestore.instance.collection('messages').add({
                                'roomId': widget.roomId,
                                'text': messageTextController.text,
                                'sender': loggedInUser.email,
                                'image': [],
                                'timestamp':
                                DateTime.now().toUtc().millisecondsSinceEpoch
                              });
                            }

                            messageTextController.clear();
                            setState(() {});
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
    ],),);
  }
}


