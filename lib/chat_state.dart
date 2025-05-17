import 'package:flutter/foundation.dart';

class ChatState with ChangeNotifier {
  String _transcript = 'Hi, How are you doing?';

  String get transcript => _transcript;

  void setTranscript(String value) {
    _transcript = value;
    notifyListeners();
  }
}
