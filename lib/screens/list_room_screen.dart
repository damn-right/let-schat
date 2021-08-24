import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';


final _firestore = Firestore.instance;
List pic=['1982.jpg','1986.jpg','1995.jpg','2090.jpg','2092.jpg','21004060.jpg','1-05.jpg','11-03.jpg','1997.jpg','2112.jpg',
          '2113.jpg','3400_7_06.jpg','20825780.jpg','1982.jpg','1986.jpg','1995.jpg','2090.jpg','2092.jpg','21004060.jpg','1-05.jpg','11-03.jpg','1997.jpg','2112.jpg',
  '2113.jpg','3400_7_06.jpg','20825780.jpg'];
final random = new Random();
class ListRoomScreen extends StatefulWidget {
  ListRoomScreen({this.roomName, this.roomID});
  static const id = 'ListRoomScreen';
  final roomName;
  final roomID;

  @override
  _ListRoomScreenState createState() => _ListRoomScreenState();
}

class _ListRoomScreenState extends State<ListRoomScreen> {
  var roomName;
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void getAlert() {
    Alert(
      context: context,
      title: 'Create New Room',
      style: AlertStyle(titleStyle: TextStyle(color: Colors.black)),
      content: TextField(
        onChanged: (value) {
          roomName = value;
        },
        decoration: InputDecoration(hintText: 'Input Room Name'),
      ),
      buttons: [
        DialogButton(
            child: Text('Create'),
            onPressed: () {
              _firestore.collection('ChatRoom').document().setData({
                'RoomId':
                    DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
                'RoomName': roomName,
                'TimeStamp': DateTime.now().toUtc().millisecondsSinceEpoch
              });
              Navigator.pop(context);
            }),
      ],
    ).show();
  }


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff181844),
          title: Text('Welcome to Galactic'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => WelcomeScreen()),
                        (Route<dynamic> route) => false);
                    _signOut();
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Image.asset(
              "images/bgg.gif",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: RoomStream(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          onPressed: () {
            getAlert();
          },
          child: Image.asset('images/astra.png'),
        ),
      );

  }
}

class RoomStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('ChatRoom').orderBy('TimeStamp').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final rooms = snapshot.data.documents;
          final List<RoomFlatButton> listFlatRoom = [];
          for (var room in rooms) {
            final roomName = room.data['RoomName'];
            final roomFlat = RoomFlatButton(
              nameRoom: roomName,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      roomId: room.data['RoomId'],
                      roomName: roomName,
                    ),
                  ),
                );
              },
              onDeletemessage: () {
                _firestore
                    .collection('ChatRoom')
                    .document(room.documentID)
                    .delete();
              },
              element: pic[random.nextInt(pic.length)],
            );
            listFlatRoom.add(roomFlat);
          }
          return ListView(
            children: listFlatRoom.reversed.toList(),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class RoomFlatButton extends StatelessWidget {

  RoomFlatButton({this.nameRoom, this.onTap, this.onDeletemessage,this.element});

  final String nameRoom;
  final Function onTap;
  final Function onDeletemessage;
  final String element;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  "Are you sure ...?",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Image.asset(
                        'images/opsy2.jpg',
                        height: 90.0,
                        width: 90.0,
                        alignment: Alignment.bottomLeft,
                      ),
                      Text(
                          "You sure you want to delete $nameRoom forever and ever...",
                          style: TextStyle(
                            color: Colors.black,
                          )),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('No Force told me not to',
                        style: TextStyle(
                          color: Colors.black,
                        )),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('100% Sure iam a Rebel',
                        style: TextStyle(
                          color: Colors.black,
                        )),
                    onPressed: () {
                      onDeletemessage();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        onTap: () {
          onTap();
        },
        child: Container(
          color: Colors.white10,
          height: 53,
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(60.0),
                child: Image(
                  image: AssetImage('images/pics/$element'),
                ),
              ),

              SizedBox(
                width: 30.0,
              ),
              Text(
                nameRoom,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
