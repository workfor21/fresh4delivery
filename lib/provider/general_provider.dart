import 'package:flutter/cupertino.dart';

class GeneralProvider extends ChangeNotifier {
  int _currentPage = 1;

  int get currentPage => _currentPage;

  void getNextPage(int num) {
    _currentPage = num;
    notifyListeners();
  }
}
