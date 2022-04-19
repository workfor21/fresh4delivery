import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fresh4delivery/config/routes/routes.dart';
import 'package:fresh4delivery/models/cart_modal.dart';
import 'package:fresh4delivery/models/hive_cart_model.dart';
import 'package:fresh4delivery/provider/added_products_provider.dart';
import 'package:fresh4delivery/provider/address_provider.dart';
import 'package:fresh4delivery/provider/cart_charges.dart';
import 'package:fresh4delivery/provider/cart_notify_provider.dart';
import 'package:fresh4delivery/provider/general_provider.dart';
import 'package:fresh4delivery/provider/getLocation_provider.dart';
import 'package:fresh4delivery/provider/get_cart_provider.dart';
import 'package:fresh4delivery/provider/get_otp_details_provider.dart';
import 'package:fresh4delivery/provider/phone_number_provider.dart';
import 'package:fresh4delivery/provider/pincode_provider.dart';
import 'package:fresh4delivery/provider/pincode_search_provider.dart';
import 'package:fresh4delivery/provider/product_map_provider.dart';
import 'package:fresh4delivery/provider/search_all_provider.dart';
import 'package:fresh4delivery/provider/total_amount_provider.dart';
import 'package:fresh4delivery/views/authentication/phone.dart';
import 'package:fresh4delivery/views/main_screen/main_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notification',
    importance: Importance.high, playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessageBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up : ${message.messageId}');
}

// void main() :::::::::::::::::::::::
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase push notification initialization
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessageBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  //Hive initialization
  await Hive.initFlutter();

  Hive.registerAdapter(HiveCartAdapter());
  await Hive.openBox<HiveCart>('cart');

  var prefs = await SharedPreferences.getInstance();
  print(prefs.getString('Id').toString().isNotEmpty);
  print(prefs.getString('Id'));
  var userId = prefs.getString('Id');
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhoneProvider()),
        ChangeNotifierProvider(create: (_) => GetOtpDetails()),
        ChangeNotifierProvider(create: (_) => CartExtraCharges()),
        ChangeNotifierProvider(create: (_) => pincodeProvider()),
        ChangeNotifierProvider(create: (_) => PincodeSearchProvider()),
        ChangeNotifierProvider(create: (_) => SearchAllProvider()),
        ChangeNotifierProvider(create: (_) => TotalAmount()),
        ChangeNotifierProvider(create: (_) => ProductMapProvider()),
        ChangeNotifierProvider(create: (_) => AddressApiProvider()),
        ChangeNotifierProvider(create: (_) => GetCartProvider()),
        ChangeNotifierProvider(create: (_) => CartNotifyProvider()),
        ChangeNotifierProvider(create: (_) => AddedproductsProvider()),
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
      ],
      builder: (context, child) {
        WidgetsFlutterBinding.ensureInitialized();

        return ScreenUtilInit(
            designSize: const Size(393, 830),
            builder: () => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: MainScreen(),
                  initialRoute: userId.toString().isEmpty || userId == null
                      ? '/phone'
                      : '/mainScreen',
                  onGenerateRoute: Routes.generateRoute,
                ));
      }));
}

// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   var userId;
//   @override
//   void initState() {
//     super.initState();
//     loggedIn();
//   }
//
//   Future loggedIn() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     var prefs = await SharedPreferences.getInstance();
//     print(prefs.getString('Id') == null);
//     // print(prefs.getString('Id'));
//     userId = prefs.getString('Id') == null ? true : false;
//   }
//
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//         designSize: const Size(393, 830),
//         builder: () => MaterialApp(
//               debugShowCheckedModeBanner: false,
//               home: DefaultTabController(length: 4, child: Phone()),
//               initialRoute: userId == null ? '/login' : 'mainScreen',
//               onGenerateRoute: Routes.generateRoute,
//             ));
//   }
// }
