import 'package:flutter/material.dart';
class RoundedButton extends StatelessWidget {
  RoundedButton({this.colour,this.title,@required this.onpressed});
  final Color colour;
  final String title;
  final Function onpressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: colour,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(

          autofocus: true,
          hoverColor: Colors.black,
          elevation: 60.0,
          onPressed: onpressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
            style: TextStyle(color: Colors.white,fontSize: 20.0,fontWeight: FontWeight.w700),

          ),

        ),
      ),
    );
  }
}