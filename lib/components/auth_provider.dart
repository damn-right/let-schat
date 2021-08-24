import 'package:flutter/material.dart';
import 'package:flash_chat/main.dart';

class Providerr extends InheritedWidget {
  final AuthService auth;
  Providerr({Key key, Widget child, this.auth,}) : super(key: key, child: child);
  @override
  bool updateShouldNotify(InheritedWidget oldWiddget)
  {
    return true;
  }
  static Providerr of(BuildContext context) =>
      (context.dependOnInheritedWidgetOfExactType<Providerr>());

}