import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fresh4delivery/config/constants/api_configurations.dart';
import 'package:fresh4delivery/models/cart_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class GetCartProvider extends ChangeNotifier {
  Future<List<CartListModel>> getCart() async {
    // try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("Id");
    var response =
        await http.post(Uri.parse(Api.cart.getcart), body: {"user_id": userId});

    // print('cart respons :::: ${response.body}');
    final data = json.decode(response.body);
    List<CartListModel> cartList = [];
    for (var i in data['cart']) {
      cartList.add(CartListModel.fromJson(i));
    }
    return cartList;
  }
}
