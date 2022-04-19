import 'package:flutter/material.dart';

void ShowSnackBar(String message, int seconds, context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      elevation: 2,
      content: Text(message),
      duration: Duration(seconds: seconds)));
}
