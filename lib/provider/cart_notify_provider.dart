import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fresh4delivery/config/constants/api_configurations.dart';
import 'package:fresh4delivery/provider/total_amount_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartNotifyProvider extends ChangeNotifier {
  bool _isCart = false;
  int _count = 0;

  bool get isCart => _isCart;
  int get count => _count;

  Future getCartnotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("Id");
    var response =
        await http.post(Uri.parse(Api.cart.getcart), body: {"user_id": userId});
    final data = json.decode(response.body);
    if (data['cart'].length > 0) {
      _isCart = true;
      _count = data['cart'].length;
      notifyListeners();
    } else {
      _isCart = false;
      _count = 0;
      notifyListeners();
    }
  }
}
