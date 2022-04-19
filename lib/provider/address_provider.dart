import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fresh4delivery/config/constants/api_configurations.dart';
import 'package:fresh4delivery/models/address_model.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddressApiProvider extends ChangeNotifier {
  Future address() async {
    AddressApi.addressList();
    notifyListeners();
  }
}
