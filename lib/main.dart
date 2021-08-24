import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/list_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'components/auth_provider.dart';


void main() { runApp(FlashChat());}

class FlashChat extends StatelessWidget {

  @override


  Widget build(BuildContext context) {

    return Providerr(
        auth: AuthService(),
        child: MaterialApp(

          debugShowCheckedModeBanner: false,
          home: HomeController(),
          routes: {
            ChatScreen.id: (context) => ChatScreen(),
            LoginScreen.id: (context) => LoginScreen(),
            RegistrationScreen.id: (context) => RegistrationScreen(),
            WelcomeScreen.id: (context) => WelcomeScreen(),
            ListRoomScreen.id: (context) => ListRoomScreen()
          },
        ),
      );
  }
}
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map((FirebaseUser user) => user?.uid,);
  Future<String> getCurrentUID() async
  {
    return (await _firebaseAuth.currentUser()).uid;
  }
}
class HomeController extends StatelessWidget {
  const HomeController({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Providerr.of(context).auth;

    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final bool signedIn = snapshot.hasData;
          return signedIn ? ListRoomScreen() : WelcomeScreen();
        }
        return Container(
          color: Colors.black,
        );
      },
    );
  }
}