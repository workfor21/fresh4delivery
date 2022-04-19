import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fresh4delivery/main.dart';
import 'package:fresh4delivery/models/user_model.dart';
import 'package:fresh4delivery/provider/cart_notify_provider.dart';
import 'package:fresh4delivery/provider/total_amount_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/utils/getLocation.dart';
import 'package:fresh4delivery/views/cart/cart.dart';
import 'package:fresh4delivery/views/category/category.dart';
import 'package:fresh4delivery/views/home/home.dart';
import 'package:fresh4delivery/views/notification/notification.dart';
import 'package:fresh4delivery/views/orders/orders.dart';
import 'package:fresh4delivery/views/profile/profile.dart';
import 'package:fresh4delivery/views/view_post/resturant_view_post.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> pages = [
    Home(),
    Category(),
    Orders(),
    Profile(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => {
          context.read<CartNotifyProvider>().getCartnotification(),
          // GetLocation.getCurrentLocation(context)
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    color: Colors.green,
                    playSound: true,
                    icon: '@mipmap/ic_launcher')));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                  title: Text(notification.title ?? ''),
                  content: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body ?? ''),
                    ],
                  )));
            });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _selectedIndex == 3
            ? AppBar(
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                        Color.fromRGBO(166, 206, 57, 1),
                        Color.fromARGB(255, 160, 224, 203),
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 255, 255, 255),
                      ])),
                ),
                automaticallyImplyLeading: false,
                title: Image.asset(
                  "assets/icons/logo1.png",
                  width: 60.w,
                ),
                actions: [
                  SizedBox(
                    width: 45,
                    child: TextButton(
                        onPressed: () {
                          print('notification');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => NotificationScreen()));
                        },
                        child:
                            SvgPicture.asset('assets/icons/notification.svg')),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 45,
                      child: Stack(children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                            child: SvgPicture.asset('assets/icons/cart.svg')),
                        context.watch<CartNotifyProvider>().count == 0
                            ? SizedBox()
                            : Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      context
                                          .watch<CartNotifyProvider>()
                                          .count
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                              )
                      ])),
                  SizedBox(width: 10)
                ],
                bottom: PreferredSize(
                  child: FutureBuilder(
                      future: HomeApi.userProfile(),
                      builder: ((context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          print('user profile ::: ' + snapshot.data.toString());
                          UserModel user = snapshot.data;
                          return Column(children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child:
                                    Image.asset("assets/images/profile.png")),
                            Text(user.user!.name ?? '',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: 5),
                            Text(user.user!.email ?? '',
                                style: TextStyle(fontSize: 12.sp)),
                            SizedBox(height: 5),
                            Text(user.user!.mobile ?? '',
                                style: TextStyle(fontSize: 12.sp)),
                          ]);
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Column(children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child:
                                      Image.asset("assets/images/profile.png")),
                              SizedBox(height: 10),
                              Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                      height: 8,
                                      width: 55,
                                      color: Colors.grey)),
                              SizedBox(height: 5),
                              Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                      height: 8,
                                      width: 85,
                                      color: Colors.grey)),
                              SizedBox(height: 5),
                              Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                      height: 8,
                                      width: 65,
                                      color: Colors.grey)),
                            ]),
                          );
                        }
                      })),
                  preferredSize: Size.fromHeight(160),
                ))
            : AppBar(
                elevation: 0,
                flexibleSpace: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[
                      Color.fromRGBO(166, 206, 57, 1),
                      Color.fromRGBO(72, 170, 152, 1)
                    ]))),
                automaticallyImplyLeading: false,
                title: Image.asset(
                  "assets/icons/logo1.png",
                  width: 60.w,
                ),
                actions: [
                  SizedBox(
                    width: 45,
                    child: TextButton(
                        onPressed: () {
                          print('notification');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => NotificationScreen()));
                        },
                        child:
                            SvgPicture.asset('assets/icons/notification.svg')),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 45,
                      child: Stack(children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                            child: SvgPicture.asset('assets/icons/cart.svg')),
                        context.watch<CartNotifyProvider>().count == 0
                            ? SizedBox()
                            : Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      context
                                          .watch<CartNotifyProvider>()
                                          .count
                                          .toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                              )
                      ])),
                  SizedBox(width: 10)
                ],
                bottom: PreferredSize(
                    child: Column(
                      children: [
                        SearchButton(),
                        // TypeAheadField(
                        //   suggestionsCallback: suggestionsCallback,
                        //   itemBuilder: itemBuilder,
                        //   onSuggestionSelected: onSuggestionSelected),
                        Container(
                            height: 30,
                            padding: const EdgeInsets.only(
                              left: 20,
                            ),
                            width: double.infinity,
                            color: Color.fromRGBO(201, 228, 125, 1),
                            child: const BottomLocationSelectionSheet())
                      ],
                    ),
                    preferredSize: Size.fromHeight(90.h))),
        bottomNavigationBar: SizedBox(
          height: 70,
          child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              iconSize: 26,
              currentIndex: _selectedIndex,
              onTap: (index) {
                _onItemTap(index);
              },
              items: [
                BottomNavigationBarItem(
                    label: 'home',
                    icon: SvgPicture.asset('assets/icons/home.svg'),
                    activeIcon: SvgPicture.asset('assets/icons/home_bold.svg')),
                BottomNavigationBarItem(
                    label: 'category',
                    icon: SvgPicture.asset('assets/icons/category.svg'),
                    activeIcon:
                        SvgPicture.asset('assets/icons/categories_bold.svg')),
                BottomNavigationBarItem(
                    label: 'orders',
                    icon: SvgPicture.asset('assets/icons/orders.svg'),
                    activeIcon:
                        SvgPicture.asset('assets/icons/orders_bold.svg')),
                BottomNavigationBarItem(
                    label: 'account',
                    icon: SvgPicture.asset('assets/icons/person.svg'),
                    activeIcon:
                        SvgPicture.asset('assets/icons/person_bold.svg')),
              ]),
        ),
        body: pages[_selectedIndex]);
  }
}
