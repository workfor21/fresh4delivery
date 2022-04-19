import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fresh4delivery/models/home_model.dart';
import 'package:fresh4delivery/models/post_model.dart';
import 'package:fresh4delivery/models/res_model.dart';
import 'package:fresh4delivery/provider/added_products_provider.dart';
import 'package:fresh4delivery/provider/cart_notify_provider.dart';
import 'package:fresh4delivery/provider/getLocation_provider.dart';
import 'package:fresh4delivery/provider/pincode_provider.dart';
import 'package:fresh4delivery/provider/pincode_search_provider.dart';
import 'package:fresh4delivery/provider/total_amount_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/utils/getLocation.dart';
import 'package:fresh4delivery/utils/pop_up_message.dart';
import 'package:fresh4delivery/utils/shimmer_widget.dart';
import 'package:fresh4delivery/utils/showSnackBar.dart';
import 'package:fresh4delivery/utils/star_rating.dart';
import 'package:fresh4delivery/views/notification/notification.dart';
import 'package:fresh4delivery/views/view_post/resturant_view_post.dart';
import 'package:fresh4delivery/widgets/header.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// class Home extends StatelessWidget {
//   static const routeName = '/home';
//   const Home({Key? key}) : super(key: key);

//   @override
//   State<Home> createState() => _HomeState();
// }

class Home extends StatefulWidget {
  static const routeName = '/home';

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var currentBackPressTime;
  List allRes = [];
  List allSup = [];

  var currentPage = 1;
  List errorWidget = [
    Image.asset('assets/images/empty.png'),
    ShimmerErrorWidget()
  ];

  @override
  void initState() {
    super.initState();
    // GetLocation.getCurrentLocation(context);
    // WidgetsBinding.instance!.addPostFrameCallback((_) => GetLocation.getCurrentLocation(context));
  }

  Future askLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
        'location on starting ::: ' + (prefs.getString('location')).toString());
    prefs.getString('location') == null
        ? GetLocation.getCurrentLocation(context)
        : null;
  }

  Future loadHome() async {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null ||
            now.difference(currentBackPressTime) > const Duration(seconds: 2)) {
          currentBackPressTime = now;
          return false;
        }
        return true;
      },
      child: Scaffold(
        // appBar: AppBar(
        //     elevation: 0,
        //     flexibleSpace: Container(
        //         decoration: BoxDecoration(
        //             gradient: LinearGradient(
        //                 begin: Alignment.topLeft,
        //                 end: Alignment.bottomRight,
        //                 colors: <Color>[
        //           Color.fromRGBO(166, 206, 57, 1),
        //           Color.fromRGBO(72, 170, 152, 1)
        //         ]))),
        //     automaticallyImplyLeading: false,
        //     title: Image.asset("assets/icons/logo1.png"),
        //     actions: [
        //       IconButton(
        //           onPressed: () {
        //             print('notification');
        //             Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                     builder: (_) => NotificationScreen()));
        //           },
        //           icon: Icon(Icons.notifications_none, color: Colors.black)),
        //       IconButton(
        //           onPressed: () {
        //             Navigator.pushNamed(context, '/cart');
        //           },
        //           icon: Icon(Icons.local_grocery_store_outlined,
        //               color: Colors.black)),
        //     ],
        //     bottom: PreferredSize(
        //         child: Column(
        //           children: [
        //             SearchButton(),
        //             // TypeAheadField(
        //             //   suggestionsCallback: suggestionsCallback,
        //             //   itemBuilder: itemBuilder,
        //             //   onSuggestionSelected: onSuggestionSelected),
        //             Container(
        //                 height: 30,
        //                 padding: const EdgeInsets.only(
        //                   left: 40,
        //                 ),
        //                 width: double.infinity,
        //                 color: Color.fromRGBO(201, 228, 125, 1),
        //                 child: const BottomLocationSelectionSheet())
        //           ],
        //         ),
        //         preferredSize: Size.fromHeight(80.h))),
        body: RefreshIndicator(
          onRefresh: loadHome,
          child: Stack(children: [
            SingleChildScrollView(
                child: FutureBuilder<HomeModel?>(
                    future: HomeApi.allData(),
                    builder: (context, AsyncSnapshot snapshot) {
                      print('snapshot data home ::::: ' +
                          snapshot.data.toString());
                      if (snapshot.hasData) {
                        HomeModel data = snapshot.data;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageCarousel(),
                            SizedBox(height: 5.h),
                            Container(
                              height: 90.h,
                              child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: data.categories!.length,
                                  itemBuilder: ((context, index) {
                                    return CircleWidget(
                                        id: data.categories![index].id
                                            .toString(),
                                        title:
                                            data.categories![index].name ?? ' ',
                                        image:
                                            "https://ebshosting.co.in${data.categories![index].image}");
                                  })),
                            ),
                            SizedBox(height: 15.h),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/near-you',
                                          arguments: false);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              width: 2,
                                              color: Color.fromRGBO(
                                                  166, 206, 57, 1)),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: <Color>[
                                                Color.fromRGBO(166, 206, 57, 1),
                                                Color.fromRGBO(72, 170, 152, 1)
                                              ])),
                                      clipBehavior: Clip.hardEdge,
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.asset(
                                                  "assets/images/carousal1.png",
                                                  width: 170.w,
                                                  height: 100.h,
                                                  fit: BoxFit.cover)),
                                          Positioned(
                                            left: -10,
                                            bottom: -10,
                                            child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 5,
                                                    left: 30,
                                                    right: 20,
                                                    bottom: 15),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: <Color>[
                                                          Color.fromRGBO(
                                                              166, 206, 57, 1),
                                                          Color.fromRGBO(
                                                              72, 170, 152, 1)
                                                        ])),
                                                child: Text("SuperMarkets",
                                                    style: TextStyle(
                                                        fontSize: 10.sp,
                                                        letterSpacing: .9,
                                                        color: Colors.white))),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/near-you',
                                          arguments: true);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: Color.fromRGBO(
                                                166, 206, 57, 1)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.asset(
                                                "assets/images/carousal1.png",
                                                width: 170.w,
                                                height: 100.h,
                                                fit: BoxFit.cover),
                                          ),
                                          Positioned(
                                            right: -10,
                                            bottom: -12,
                                            child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 5,
                                                    left: 20,
                                                    right: 30,
                                                    bottom: 15),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: <Color>[
                                                          Color.fromRGBO(
                                                              72, 170, 152, 1),
                                                          Color.fromRGBO(
                                                              166, 206, 57, 1),
                                                        ])),
                                                child: Text("Restaurants",
                                                    style: TextStyle(
                                                        fontSize: 10.sp,
                                                        letterSpacing: .9,
                                                        color: Colors.white))),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Headerwidget(
                                title: "Top Restaurants",
                                route: '/restaurantsviewmore',
                                type: "Restaurants"),
                            SizedBox(height: 20),
                            Container(
                                constraints: BoxConstraints(
                                    maxHeight: 180, minHeight: 160),
                                child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: (data.restaurants!.length +
                                        data.nrestaurants!.length),
                                    itemBuilder: ((context, index) {
                                      for (var i in data.restaurants!) {
                                        i['status'] = true;
                                        allRes.add(i);
                                      }
                                      for (var i in data.nrestaurants!) {
                                        i['status'] = false;
                                        allRes.add(i);
                                      }

                                      if (allRes.length != 0) {
                                        return Cards(
                                            status: allRes[index]['status'],
                                            route: '/restuarant-view-post',
                                            itemId:
                                                allRes[index]['id'].toString(),
                                            title: allRes[index]['name'] ?? '',
                                            time: "23",
                                            ratings: 3,
                                            image:
                                                "https://ebshosting.co.in${allRes[index]['logo']}");
                                      } else {
                                        return Center(
                                          child: Image.asset(
                                              'assets/images/empty.png'),
                                        );
                                      }
                                    }))),
                            SizedBox(height: 20),
                            Headerwidget(
                                title: "Top Super Markets",
                                route: '/supermarketsviewmore',
                                type: "Supermarkets"),
                            SizedBox(height: 20),
                            Container(
                                constraints: BoxConstraints(
                                    maxHeight: 175, minHeight: 160),
                                child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: (data.supermarkets!.length +
                                        data.nsupermarkets!.length),
                                    itemBuilder: ((context, index) {
                                      for (var i in data.supermarkets!) {
                                        i['status'] = true;
                                        allSup.add(i);
                                      }
                                      for (var i in data.nsupermarkets!) {
                                        i['status'] = false;
                                        allSup.add(i);
                                      }
                                      if (allSup.length != 0) {
                                        return Cards(
                                            status: allSup[index]['status'],
                                            itemId:
                                                allSup[index]['id'].toString(),
                                            route: '/supermarket-view-post',
                                            title: allSup[index]['name'],
                                            time: allSup[index]
                                                ['delivery_time'],
                                            image:
                                                "https://ebshosting.co.in${allSup[index]['logo']}");
                                      } else {
                                        return Center(
                                          child: Image.asset(
                                              'assets/images/empty.png'),
                                        );
                                      }
                                    }))),
                            SizedBox(height: 20),
                            Headerwidget(
                                isMore: false,
                                title: "Top Products",
                                route: '/productsviewmore',
                                type: "Products"),
                            SizedBox(height: 20),
                            ///////////////////////////////////////////////
                            //add to cart button -- plus and minus button//
                            Container(
                                constraints: BoxConstraints(
                                    maxHeight: 230, minHeight: 160),
                                child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemCount: data.restproducts!.length,
                                    itemBuilder: ((context, index) {
                                      /////-----buttonState and quantity-----/////
                                      List cartList = context
                                          .watch<AddedproductsProvider>()
                                          .cartList;

                                      context
                                          .read<AddedproductsProvider>()
                                          .addState(false);

                                      for (var i in cartList) {
                                        if (data.restproducts![index]['id'] ==
                                            i['product_id'].toString()) {
                                          context
                                              .read<AddedproductsProvider>()
                                              .getQuantity(i['quantity']);
                                          context
                                              .read<AddedproductsProvider>()
                                              .addState(true);
                                          print(
                                              '${data.restproducts![index]['id']} ::; ${i}');
                                          print('button state ::: ' +
                                              context
                                                  .read<AddedproductsProvider>()
                                                  .buttonState
                                                  .toString());
                                        }
                                      }

                                      if (data.restaurants!.length != 0) {
                                        return AddToCartHomeButton(
                                          buttonState: context
                                              .watch<AddedproductsProvider>()
                                              .buttonState,
                                          quantity: context
                                              .watch<AddedproductsProvider>()
                                              .quantity,
                                          offerprice: data.restproducts![index]
                                                  ['offerprice']
                                              .toString(),
                                          status: true,
                                          title: data.restproducts![index]
                                              ['name'],
                                          price: data.restproducts![index]
                                                  ['price']
                                              .toString(),
                                          image: data.restproducts![index]
                                              ['image'],
                                          hasUnit: data.restproducts![index]
                                              ['has_units'],
                                          unit: ["products.units"],
                                          type: data.restproducts![index]
                                              ['shop_type'],
                                          productId: data.restproducts![index]
                                              ['id'],
                                          shopId: data.restproducts![index]
                                              ['shop_id'],
                                        );
                                      } else {
                                        return Center(
                                          child: Image.asset(
                                              'assets/images/empty.png'),
                                        );
                                      }
                                    }))),
                            SizedBox(height: 20),
                            ImageCarousel(
                              sorf: false,
                            )
                          ],
                        );
                      } else {
                        return ShimmerWidget();
                      }
                    })),
            Positioned(
                height: 50,
                bottom: 2,
                left: 4,
                right: 4,
                child: context.watch<CartNotifyProvider>().isCart == true
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color.fromRGBO(166, 206, 57, 1),
                                Color.fromRGBO(72, 170, 152, 1)
                              ]),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                '${context.watch<CartNotifyProvider>().count} items | ₹${context.watch<TotalAmount>().totalAmount}',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400)),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                              child: Row(
                                children: [
                                  Text('View Cart',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400)),
                                  SvgPicture.asset(
                                      'assets/icons/cart_white.svg',
                                      width: 15)
                                ],
                              ),
                            )
                          ],
                        ))
                    : SizedBox())
          ]),
        ),
      ),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: 7,
      itemBuilder: ((context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(100),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  "assets/images/carousal1.png",
                  fit: BoxFit.cover,
                  width: 80.w,
                )),
          ),
        );
      }),
    );
  }
}

class ShimmerErrorWidget extends StatelessWidget {
  const ShimmerErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: 5,
          itemBuilder: ((context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Cards(
                route: '',
                isRating: false,
              ),
            );
          })),
    );
  }
}

class AddToCartHomeButton extends HookWidget {
  bool? buttonState;
  int? quantity;
  bool? status;
  String? title;
  String? unitname;
  String? price;
  String? offerprice;
  String? image;
  double ratings;
  bool isRating;
  List? unit;
  String? type;
  dynamic hasUnit;
  dynamic shopId;
  dynamic productId;
  AddToCartHomeButton(
      {Key? key,
      this.quantity,
      this.buttonState,
      this.image,
      this.status,
      this.isRating = true,
      this.ratings = 0,
      this.unitname,
      this.price,
      this.offerprice,
      this.title,
      this.hasUnit,
      this.type,
      this.unit,
      this.shopId,
      this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentButton = useState(buttonState);
    final currentNumber = useState(quantity);
    return Container(
      margin: const EdgeInsets.only(right: 5, left: 5),
      padding: const EdgeInsets.only(left: 2, right: 2, top: 4),
      width: 120.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 110.h,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CachedNetworkImage(
              imageUrl: "https://ebshosting.co.in$image",
              errorWidget: (context, url, error) =>
                  Image.asset('assets/images/empty.png', height: 110.h),
            ),
            // Image.network(
            //   image,
            //   fit: BoxFit.cover,
            // ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      constraints: BoxConstraints(maxHeight: 30, minHeight: 10),
                      width: 100,
                      child: Text(title.toString(),
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 2, right: 2),
                  // height: 20.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₹$price",
                          style: TextStyle(
                              fontSize: 9.sp,
                              color: Color.fromRGBO(100, 120, 47, 1)))
                    ],
                  ),
                ),
                Column(
                  children: [
                    currentButton.value == false
                        ? GestureDetector(
                            onTap: () async {
                              if (status == false) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "This product is not currently available."),
                                    duration: Duration(seconds: 1)));
                              } else {
                                print('has unit :::: ${hasUnit}');
                                if (hasUnit.toString() == 1.toString()) {
                                  print('unit :::::: ' + unit.toString());
                                  showModalBottomSheet(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10))),
                                      isDismissible: true,
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) =>
                                          DraggableScrollableSheet(
                                              expand: false,
                                              initialChildSize: .35,
                                              minChildSize: 0.35,
                                              maxChildSize: 0.35,
                                              builder: (BuildContext context,
                                                  ScrollController
                                                      scrollController) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 20),
                                                  child: ListView.builder(
                                                      itemCount: unit!.length,
                                                      itemBuilder:
                                                          ((context, index) {
                                                        UnitModel unitList =
                                                            unit![index];
                                                        print(unitList.id);
                                                        return SubProductsViewPost(
                                                          productname: title,
                                                          offerprice: unitList
                                                              .offerprice
                                                              .toString(),
                                                          unitId: unitList.id
                                                              .toString(),
                                                          type: type,
                                                          shopId: shopId,
                                                          productId: unitList
                                                              .productId,
                                                          name: unitList.name
                                                              .toString(),
                                                          price: unitList.price
                                                              .toString(),
                                                          status: unitList
                                                              .status
                                                              .toString(),
                                                        );
                                                      })),
                                                );
                                              }));
                                } else {
                                  // currentButton.value = true;
                                  context
                                      .read<CartNotifyProvider>()
                                      .getCartnotification();
                                  context
                                      .read<AddedproductsProvider>()
                                      .addProductId(productId);
                                  print('$type :: $productId :: $shopId');
                                  var response = await CartApi.addToCart(
                                      type, productId, shopId, 0, context);
                                  if (response == true) {
                                    context.read<TotalAmount>().GetAllAmounts();
                                    ShowSnackBar(
                                        'product added to cart', 2, context);
                                  } else {
                                    ShowSnackBar(
                                        "Some error occured.", 2, context);
                                  }
                                  print('add to cart');
                                }
                              }
                            },
                            child: Container(
                                height: 30.h,
                                width: 80.w,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: <Color>[
                                          const Color.fromRGBO(166, 206, 57, 1),
                                          const Color.fromRGBO(72, 170, 152, 1)
                                        ]),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Center(
                                    child: Text("Add To Cart",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500)))))
                        : Container(
                            height: 30.h,
                            width: 90.w,
                            // margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 2)),
                            child:
                                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              GestureDetector(
                                  onTap: () async {
                                    print('minus');
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    var cart = prefs.getString('cart');
                                    var cartBody = jsonDecode(cart!);
                                    var dcartBody = jsonDecode(cartBody);

                                    for (var i in dcartBody['cart']) {
                                      if (title.toString() ==
                                          i['productname'].toString()) {
                                        context
                                            .read<TotalAmount>()
                                            .GetAllAmounts();
                                        currentNumber.value =
                                            currentNumber.value! - 1;
                                        if (currentNumber.value! <= 0)
                                          currentNumber.value = 1;

                                        var response = await CartApi.updateCart(
                                            i['id'].toString(),
                                            currentNumber.value.toString(),
                                            context);
                                        print(response);
                                      }
                                    }
                                  },
                                  child: Container(
                                      // padding: const EdgeInsets.symmetric(horizontal: 1),
                                      width: 15.w,
                                      height: 15.h,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Divider(
                                        thickness: 2,
                                        color: Colors.white,
                                      ))),
                              SizedBox(width: 10),
                              Text("${currentNumber.value}"), //quantity
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () async {
                                    print('add');
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    var cart = prefs.getString('cart');
                                    var cartBody = jsonDecode(cart!);
                                    var dcartBody = jsonDecode(cartBody);

                                    for (var i in dcartBody['cart']) {
                                      print("${title} :::: ${i['unit_id']}");
                                      print(title == i['unit_id']);
                                      if (title.toString() ==
                                          i['productname'].toString()) {
                                        context
                                            .read<TotalAmount>()
                                            .GetAllAmounts();
                                        currentNumber.value =
                                            currentNumber.value! + 1;
                                        if (currentNumber.value! >= 10)
                                          currentNumber.value = 10;
                                        var response = await CartApi.updateCart(
                                            i['id'].toString(),
                                            currentNumber.value.toString(),
                                            context);
                                        print(response);
                                        print(i);
                                      }
                                    }
                                  },
                                  child: Container(
                                      width: 15.w,
                                      height: 15.h,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: Icon(Icons.add,
                                          color: Colors.white, size: 15))),
                            ])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Future getCartDetails() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var cart = prefs.getString('cart');
  //   var cartbody = json.decode(cart!);

  //   List<CartListModel> data = json.decode(cartbody['cart']);
  //   return data;
  // }
}

class ImageCarousel extends HookWidget {
  bool sorf;
  ImageCarousel({
    Key? key,
    this.sorf = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _index = useState(0);
    final _imageState = useState(0);
    return FutureBuilder(
        future: sorf ? HomeApi.fbanner() : HomeApi.sbanner(),
        builder: ((context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<BannerModel> data = snapshot.data;
            return Column(
              children: [
                CarouselSlider.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index, realIndex) {
                      BannerModel banners = data[index];
                      return CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 1,
                        imageUrl:
                            "https://ebshosting.co.in/${banners.image.toString()}",
                        errorWidget: (context, url, error) =>
                            Image.asset('assets/images/empty.png'),
                      );

                      // Image.network(
                      //     "https://ebshosting.co.in/${banners.image.toString()}",
                      //     fit: BoxFit.cover,
                      //     width: MediaQuery.of(context).size.width * 1);
                    },
                    options: CarouselOptions(
                        aspectRatio: 10 / 4.5,
                        viewportFraction: 1,
                        autoPlay: true,
                        onPageChanged: (index, reason) {
                          _index.value = index;
                          _imageState.value = index;
                        })),
                !sorf
                    ? SizedBox()
                    : SizedBox(
                        height: 20,
                        child: AnimatedSmoothIndicator(
                            activeIndex: _index.value,
                            count: data.length,
                            effect: WormEffect(
                                dotWidth: 10.w,
                                dotHeight: 5.h,
                                dotColor: Colors.grey.shade300,
                                activeDotColor:
                                    Color.fromRGBO(201, 228, 125, 1),
                                strokeWidth: 1)))
              ],
            );
          } else {
            return AspectRatio(
              aspectRatio: 10 / 4.5,
              child: Image.asset(
                "assets/images/splash_logo2.png",
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            );
          }
        }));
  }
}

class CircleWidget extends StatelessWidget {
  String? id;
  String title;
  String image;
  CircleWidget(
      {Key? key,
      this.title = 'not available',
      this.id,
      this.image =
          "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('category-One');
        Navigator.pushNamed(context, '/viewall', arguments: id);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 5, left: 5),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                  width: 65.w,
                  height: 65.h,
                  imageUrl: image,
                  placeholder: (context, url) =>
                      Image.asset('assets/images/empty.png', fit: BoxFit.cover),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/empty.png'),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(title,
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }
}

class Cards extends StatelessWidget {
  String? type;
  String? shopId;
  String? unitId;
  bool? status;
  String route;
  String? itemId;
  String title;
  String time;
  double ratings;
  String image;
  bool isRating;
  Cards(
      {Key? key,
      this.type,
      this.shopId,
      this.unitId,
      this.status,
      required this.route,
      this.itemId,
      this.title = "not available",
      this.time = "!!",
      this.image =
          "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png",
      this.ratings = 4.5,
      this.isRating = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (status == true) {
          Navigator.pushNamed(context, route, arguments: itemId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("This restaurant is unavailable!!"),
              duration: Duration(milliseconds: 500)));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 5, left: 5),
        padding: const EdgeInsets.only(left: 2, right: 2, top: 4),
        width: 120.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 110.h,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: CachedNetworkImage(
                imageUrl: image,
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/empty.png'),
              ),
              // Image.network(
              //   image,
              //   fit: BoxFit.cover,
              // ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      constraints: BoxConstraints(maxHeight: 30, minHeight: 10),
                      width: 110,
                      child: Text(title,
                          style: TextStyle(
                              fontSize: 10.sp, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(status == true ? 'Available' : 'Not avilable',
                          style: TextStyle(
                            color: status == true ? Colors.green : Colors.red,
                            fontSize: 10.sp,
                          )),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 2, right: 2),
                  height: 20.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isRating
                          ? StarRating(
                              rating: ratings,
                              iconsize: 12,
                            )
                          : SizedBox(),
                      Text(time,
                          style: TextStyle(
                              fontSize: 8.sp,
                              color: Color.fromRGBO(100, 120, 47, 1)))
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BottomLocationSelectionSheet extends StatefulWidget {
  const BottomLocationSelectionSheet({Key? key}) : super(key: key);

  @override
  State<BottomLocationSelectionSheet> createState() =>
      _BottomLocationSelectionSheetState();
}

class _BottomLocationSelectionSheetState
    extends State<BottomLocationSelectionSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    context.read<pincodeProvider>().isDisplayPin();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 15),
        TextButton(
          child: Text("${context.watch<pincodeProvider>().pincode}",
              style: TextStyle(color: Colors.black, fontSize: 12)),
          onPressed: () {
            showModalBottomSheet(
                isDismissible: true,
                isScrollControlled: true,
                context: context,
                builder: (context) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: .2,
                    minChildSize: 0.2,
                    maxChildSize: 0.2,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Where do you want the delivery",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              SizedBox(height: 7),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "Select the pincode to see product availability",
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w300)),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SelectLocationButton(
                                    title: "Add Address",
                                    icon: Icons.location_on_outlined,
                                    function: () {
                                      print('add address');
                                      Navigator.pop(context);
                                      Navigator.pushNamed(
                                          context, '/add-new-address');
                                    },
                                  ),
                                  SelectLocationButton(
                                    title: "Detect Location",
                                    icon: Icons.my_location_sharp,
                                    function: () {
                                      GetLocation.getCurrentLocation(context);
                                      Navigator.pop(context);
                                      print('location detection');
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }));
          },
        )
      ],
    );

    // RichText(
    //     text: TextSpan(children: [
    //   TextSpan(
    //       text: "Delivery to :", style: TextStyle(color: Colors.grey.shade600)),
    //   TextSpan(
    //       text: " ${context.watch<pincodeProvider>().pincode}",
    //       style: TextStyle(color: Colors.grey.shade600),
    //       recognizer: TapGestureRecognizer()
    //         ..onTap = () async {
    //           final response = await RestaurantApi.viewAll();
    //           final pref = await SharedPreferences.getInstance();
    //           print(pref.getString('Id'));
    //           print(response);
    //           print('location select manually');
    //           showModalBottomSheet(
    //               isDismissible: true,
    //               isScrollControlled: true,
    //               context: context,
    //               builder: (context) => DraggableScrollableSheet(
    //                   expand: false,
    //                   initialChildSize: .3,
    //                   minChildSize: 0.3,
    //                   maxChildSize: 0.3,
    //                   builder: (BuildContext context,
    //                       ScrollController scrollController) {
    //                     return SingleChildScrollView(
    //                       child: Padding(
    //                         padding: const EdgeInsets.symmetric(horizontal: 20),
    //                         child: Column(
    //                           children: [
    //                             SizedBox(height: 20),
    //                             Row(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 Text("Where do you want the delivery",
    //                                     style: TextStyle(
    //                                         fontSize: 14.sp,
    //                                         fontWeight: FontWeight.w600)),
    //                               ],
    //                             ),
    //                             SizedBox(height: 7),
    //                             Row(
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 Text(
    //                                     "Select the pincode to see product availability",
    //                                     style: TextStyle(
    //                                         fontSize: 12.sp,
    //                                         fontWeight: FontWeight.w300)),
    //                               ],
    //                             ),
    //                             SizedBox(height: 20),
    //                             Row(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               children: [
    //                                 SelectLocationButton(
    //                                   title: "Add Address",
    //                                   icon: Icons.location_on_outlined,
    //                                   function: () {
    //                                     print('add address');
    //                                     Navigator.pushNamed(
    //                                         context, '/add-new-address');
    //                                   },
    //                                 ),
    //                               ],
    //                             ),
    //                             SizedBox(height: 10),
    //                             Row(
    //                               mainAxisAlignment:
    //                                   MainAxisAlignment.spaceAround,
    //                               children: [
    //                                 SelectLocationButton(
    //                                   title: "Enter Pincode",
    //                                   icon: Icons.location_on_outlined,
    //                                   function: () {
    //                                     Navigator.pop(context);
    //                                     show(context);
    //                                     print('enter pincode');
    //                                   },
    //                                 ),
    //                                 SelectLocationButton(
    //                                   title: "Detect Location",
    //                                   icon: Icons.my_location_sharp,
    //                                   function: () {
    //                                     GetLocation.getCurrentLocation(context);
    //                                     print('location detection');
    //                                   },
    //                                 ),
    //                               ],
    //                             )
    //                           ],
    //                         ),
    //                       ),
    //                     );
    //                   }));
    //         })
    // ]));
  }
}

class SelectLocationButton extends StatelessWidget {
  String? title;
  IconData? icon;
  Function? function;
  SelectLocationButton({Key? key, this.title, this.icon, this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => function!(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6)),
          child: TextButton(
              onPressed: () => function!(),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 15, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  title ?? '',
                  style: TextStyle(color: Colors.green),
                )
              ])),
        )
        // Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        //     decoration: BoxDecoration(
        //         border: Border.all(width: 1, color: Colors.grey.shade400),
        //         borderRadius: BorderRadius.circular(6)),
        //     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        //       Icon(icon, size: 15, color: Colors.green),
        //       SizedBox(width: 10),
        //       Text(
        //         title ?? '',
        //         style: TextStyle(color: Colors.green),
        //       )
        //     ])),
        );
  }
}

void show(BuildContext context) async {
  showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: .5,
          minChildSize: 0.5,
          maxChildSize: 0.5,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Select pincode",
                            style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Container(
                      height: 65,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          context.read<PincodeSearchProvider>().getPincode(val);
                        },
                      )),
                  FutureBuilder(
                      future: context
                          .watch<PincodeSearchProvider>()
                          .searchResults(),
                      builder: ((context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          List<String> data = snapshot.data;
                          return ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: ((context, index) {
                                String pincodes = data[index];
                                return GestureDetector(
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    var pin =
                                        prefs.setString("pincode", pincodes);
                                    context
                                        .read<pincodeProvider>()
                                        .updatepincode(pincodes);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/mainScreen');
                                    print(await prefs.getString("pincode"));
                                    print('pincode received');
                                  },
                                  child: Container(
                                      height: 50,
                                      margin: const EdgeInsets.only(
                                          left: 20, right: 20, top: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 2,
                                              color: Colors.grey.shade300)),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_outlined),
                                          SizedBox(width: 20),
                                          Text(pincodes.toString()),
                                        ],
                                      )),
                                );
                              }));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      }))
                ],
              ),
            );
          }));
}
