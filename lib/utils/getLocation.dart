import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fresh4delivery/provider/pincode_provider.dart';
import 'package:fresh4delivery/utils/showSnackBar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetLocation {
  static Future getCurrentLocation(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? serviceEnabled;
    LocationPermission permission;

    serviceEnabled == await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled == true) {
      ShowSnackBar('Please keep your location on.', 2, context);
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ShowSnackBar('Location permission is denied.', 2, context);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ShowSnackBar('Permission is denied forever.', 2, context);
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      var pincode = '${place.postalCode}';
      var location =
          '${place.administrativeArea} ${place.subAdministrativeArea} ${place.locality} ${place.street} ${place.postalCode}';
      print(location);
      prefs.setString('display_pin', pincode);
      prefs.setString('location', location);
      context.read<pincodeProvider>().setDummy(location);
      print('place ::: ' + place.toString());
    } catch (e) {
      print(e);
    }
  }
}
