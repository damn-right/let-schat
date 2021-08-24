import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/list_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../constants.dart';
//ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  static const id = 'login_screen';
  var errorMessage;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email;
  String password;
  bool isSpindel = false;
  bool _visible=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: ModalProgressHUD(
        inAsyncCall: isSpindel,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/lg.jpg'),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                textAlign: TextAlign.justify,
                onChanged: (value) {
                  email = value;
                  //Do something with the user input.
                },
                decoration: kTextFieldDescoration.copyWith(
                    hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  textAlign: TextAlign.justify,
                  obscureText: _visible,
                  onChanged: (value) {
                    password = value;
                    //Do something with the user input.
                  },
                  decoration: kTextFieldDescoration.copyWith(hintText: 'Enter your password',
                   suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _visible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          _visible = !_visible;
                        });
                      },
                    ),
                  ),

              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async {
                      //Implement login functionality.
                      setState(() {
                        isSpindel = true;
                      });
                      try {
                        var user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                        if (user != null) {
                          Navigator.pushNamed(context, ListRoomScreen.id);
                          setState(() {
                            isSpindel = false;
                            print(_auth.signInWithEmailAndPassword(email: email, password: password));
                          });
                        }


                      } catch (e) {
                        setState(() {
                          isSpindel = false;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Flexible(
                                child: AlertDialog(
                                  backgroundColor: Color(0xff460BA1),
                                  title: Text("oppsy" , style: TextStyle(color: Colors.white,),),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Image.asset('images/opsy.jpg',height:60.0,width:60.0,alignment: Alignment.bottomLeft,),
                                        Text(e.message,style: TextStyle(color: Colors.white,)),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child:  Text('ok', style: TextStyle(color: Colors.white,)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      }
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: Text(
                      'Log In',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
