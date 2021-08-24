import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_chat/screens/chat_image_view.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender,
      this.text,
      this.isMe,
      this.imagesList,
      this.context,
      this.onDeletemessage});

  final String sender;
  final String text;
  final bool isMe;
  final BuildContext context;
  final List<dynamic> imagesList;
  final Function onDeletemessage;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: GestureDetector(
        onLongPress: (){
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
                          "You sure you want to delete this text",
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
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              sender,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            //TODO: text content
            (text != '')
                ? Material(
                    borderRadius: isMe
                        ? BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0))
                        : BorderRadius.only(
                            bottomLeft: Radius.circular(30.0),
                            bottomRight: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                    elevation: 5.0,
                    color: isMe ? Color(0xffE9D4A8) : Color(0xffAD9E7D),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.black : Colors.black,
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  )
                : Container(),
            //TODO: image holder
            isMeListImage()
          ],
        ),
      ),
    );
  }

  isMeListImage() {
    if (isMe) {
      return Row(
        children: <Widget>[
          Expanded(flex: 1, child: Container()),
          Expanded(flex: 2, child: getImageList()),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          Expanded(flex: 2, child: getImageList()),
          Expanded(flex: 1, child: Container()),
        ],
      );
    }
  }

  //TODO load image list
  Widget getImageList() {
    if (imagesList == null || imagesList.length == 0) {
      return Container();
    } else {
      return GridView.count(
        crossAxisCount: 1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(imagesList.length, (index) {
          String image = imagesList[index];
          return Padding(
            padding: EdgeInsets.all(3),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageProductView(
                              onlineImage: image,
                            )));
              },
              child: CachedNetworkImage(
                imageUrl: image,
                placeholder: (context, url) => Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          );
        }),
      );
    }
  }
}
