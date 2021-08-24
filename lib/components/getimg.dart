import 'dart:math';
import 'package:flutter/foundation.dart';
 class Getimg extends ChangeNotifier
 {
   List pic=['1982.jpg','1986.jpg','1995.jpg','2090.jpg','2092.jpg','21004060.jpg',];
   get epic
   {
     return getimage();
   }
   void getimage()
   {
     final random = new Random();
     var element = pic[random.nextInt(pic.length)];
     notifyListeners();
     return element;
   }
 }