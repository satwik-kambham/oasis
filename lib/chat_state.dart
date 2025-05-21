import 'package:flutter/foundation.dart';

class ChatState with ChangeNotifier {
  String _transcript = 'Hi, How are you doing?';
  String _result = '';

  String get transcript => _transcript;
  String get result => _result;

  void setTranscript(String value) {
    _transcript = value;
    notifyListeners();
  }
  
  void setResult(String value) {
    _result = value;
    notifyListeners();
  }
}
