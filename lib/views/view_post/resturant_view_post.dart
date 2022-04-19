import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fresh4delivery/config/constants/api_configurations.dart';
import 'package:fresh4delivery/models/cart_modal.dart';
import 'package:fresh4delivery/models/hive_cart_model.dart';
import 'package:fresh4delivery/models/post_model.dart';
import 'package:fresh4delivery/provider/added_products_provider.dart';
import 'package:fresh4delivery/provider/cart_notify_provider.dart';
import 'package:fresh4delivery/provider/general_provider.dart';
import 'package:fresh4delivery/provider/get_cart_provider.dart';
import 'package:fresh4delivery/provider/total_amount_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/utils/pop_up_message.dart';
import 'package:fresh4delivery/utils/showSnackBar.dart';
import 'package:fresh4delivery/utils/star_rating.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class RestuarantViewPost extends StatefulWidget {
  @override
  State<RestuarantViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<RestuarantViewPost>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    List errorWidget = [
      Image.asset('assets/images/empty.png'),
      CircularProgressIndicator()
    ];
    final arguments = ModalRoute.of(context)?.settings.arguments;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () async {
              // await CartApi.updateCartinSharedPreferences();
              Navigator.pushNamed(context, '/cart');
            },
            child: Container(
              width: 28.w,
              height: 15.h,
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // color: Colors.blue
                color: Colors.white70,
              ),
              child: SvgPicture.asset('assets/icons/cart.svg'),
            ),
          )
        ],
        title: GestureDetector(
          onTap: () async {
            // await CartApi.updateCartinSharedPreferences();
            Navigator.pop(context);
          },
          child: Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(171, 255, 255, 255),
              ),
              child: const Icon(Icons.keyboard_arrow_left_rounded,
                  color: Colors.black, size: 28)),
        ),
      ),
      body: FutureBuilder<PostModal?>(
        future: RestaurantApi.getOneRestaurant(arguments),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            int categoryLength = data?.category.values.length ?? 0;
            final shop = data!.shop;
            print('banner pic' + data.shop.banner);
            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 300.h,
                    child: Stack(children: [
                      CachedNetworkImage(
                        fit: BoxFit.fill,
                        // height: 100,
                        width: MediaQuery.of(context).size.width,
                        imageUrl: "https://ebshosting.co.in${shop.photo}",
                        errorWidget: (context, url, error) => Image.network(
                            "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png"),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7),
                            width: MediaQuery.of(context).size.width,
                            height: 65.h,
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: <Color>[
                                  const Color.fromARGB(218, 166, 206, 57),
                                  Color.fromARGB(195, 72, 170, 152)
                                ])),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop.name.toString(),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      ),
                                      StarRating(
                                        iconsize: 13,
                                        rating: shop.rating.toDouble(),
                                      )
                                    ]),
                                Text(shop.city.toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12))
                              ],
                            )),
                      )
                    ]),
                  ),
                  DefaultTabController(
                      length: categoryLength,
                      child: Column(children: [
                        Container(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.only(
                              top: 20, left: 20, right: 20),
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 0)),
                          child: TabBar(
                            indicator: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.grey.shade400)),
                            isScrollable: true,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black,
                            tabs: data.category.values.map((e) {
                              return Tab(
                                child: Text(e, style: TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                              maxHeight: 440.h, minHeight: 400.h),
                          child: TabBarView(
                              children: List<Widget>.generate(categoryLength,
                                  (index) {
                            final productList = data.products[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: SingleChildScrollView(
                                ////////////////
                                child: Column(
                                  children: data.products.map((e) {
                                    List cartAddedproducts = context
                                        .watch<AddedproductsProvider>()
                                        .prouctId;

                                    List cartList = context
                                        .watch<AddedproductsProvider>()
                                        .cartList;
                                    print('cart from provider ::: ' +
                                        cartList.toString());

                                    context
                                        .read<AddedproductsProvider>()
                                        .addState(false);

                                    for (var i in cartList) {
                                      if (e.id.toString() ==
                                              i['product_id'].toString() &&
                                          i['unit_id'] == 0) {
                                        context
                                            .read<AddedproductsProvider>()
                                            .getQuantity(i['quantity']);
                                        context
                                            .read<AddedproductsProvider>()
                                            .addState(true);
                                        print('${e.id} ::; ${i}');
                                        print('button state ::: ' +
                                            context
                                                .read<AddedproductsProvider>()
                                                .buttonState
                                                .toString());
                                      }
                                    }

                                    if (data.category.keys.elementAt(index) ==
                                        e.catId.toString()) {
                                      // print('hasUnit::::::' + e.hasUnits);
                                      return ViewPostsWidget(
                                        buttonState: context
                                            .watch<AddedproductsProvider>()
                                            .buttonState,
                                        quantity: context
                                            .watch<AddedproductsProvider>()
                                            .quantity,
                                        offerprice:
                                            productList.offerprice.toString(),
                                        productname: productList.name,
                                        unitId: 0,
                                        unit: e.units,
                                        hasUnit: e.hasUnits,
                                        type: e.shopType.toString(),
                                        shopId: e.shopId,
                                        productId: e.id,
                                        image: e.image,
                                        name: e.name,
                                        price: e.price.toString(),
                                        status: e.status,
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }).toList(),
                                ),
                              ),
                            );
                          })),
                        ),
                      ])),
                ],
              ),
            );
          } else {
            return Center(
              child: errorWidget[1],
            );
          }
        }),
      ),
    );
  }

  List? cartList;

  getSharedCart() async {
    final prefs = await SharedPreferences.getInstance();
    var cart = prefs.getString('cart');
    var cartBody = jsonDecode(cart!);
    return cartBody;
  }
}

class ViewPostsWidget extends HookWidget {
  List? unit;
  bool isImage;
  dynamic hasUnit;
  dynamic unitId;
  String? type;
  dynamic shopId;
  dynamic productId;
  int? itemCount;
  String? image;
  String productname;
  String name;
  bool? buttonState;
  String offerprice;
  String price;
  String status;
  int? quantity;
  ViewPostsWidget(
      {Key? key,
      this.buttonState,
      this.unit,
      this.quantity,
      this.isImage = true,
      this.unitId,
      this.hasUnit = 0,
      this.type,
      this.shopId,
      this.productId,
      this.itemCount,
      this.image,
      required this.offerprice,
      required this.price,
      required this.productname,
      required this.name,
      required this.status})
      : super(key: key);

  // @override
  // void initState() {
  //   WidgetsBinding.instance!.addPostFrameCallback((_) => getOneCart());
  // }

  @override
  Widget build(BuildContext context) {
    final currentButton = useState(buttonState);
    final currentNumber = useState(quantity);

    return Container(
        // padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(bottom: 15),
        // height: 100.h,
        width: 350.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 2.w)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            isImage == true
                ? Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            fit: BoxFit.contain,
                            height: 100.h,
                            width: 100.w,
                            imageUrl: "https://ebshosting.co.in$image",
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/empty.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Image.network(W
                        //   image!.isEmpty || image == null
                        //       ? "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png"
                        //       : "https://ebshosting.co.in/${image.toString()}",
                        //   fit: BoxFit.cover,

                        // ),
                      ],
                    ),
                  )
                : const SizedBox(),
            SizedBox(width: 15.w),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 5.h),
                  Text("₹$price", style: TextStyle(fontSize: 12.sp)),
                  SizedBox(height: 5.h),
                  Text(status,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: status == "Available"
                              ? Colors.green
                              : Colors.red)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  currentButton.value == false
                      ? GestureDetector(
                          onTap: () async {
                            context
                                .read<AddedproductsProvider>()
                                .addProductId(productId);
                            if (int.parse(hasUnit) == 1) {
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
                                              padding: const EdgeInsets.only(
                                                  left: 20, right: 20, top: 20),
                                              child: ListView.builder(
                                                  itemCount: unit!.length,
                                                  itemBuilder:
                                                      ((context, index) {
                                                    UnitModel unitList =
                                                        unit![index];
                                                    print(unitList.id);

                                                    //////////////////////
                                                    List cartList = context
                                                        .watch<
                                                            AddedproductsProvider>()
                                                        .cartList;

                                                    context
                                                        .read<
                                                            AddedproductsProvider>()
                                                        .addState(false);

                                                    for (var i in cartList) {
                                                      if (unitList.id
                                                              .toString() ==
                                                          i['unit_id']
                                                              .toString()) {
                                                        context
                                                            .read<
                                                                AddedproductsProvider>()
                                                            .getQuantity(
                                                                i['quantity']);
                                                        context
                                                            .read<
                                                                AddedproductsProvider>()
                                                            .addState(true);
                                                        print(
                                                            '${unitList.id} ::: ${i}');
                                                        print('button state ::: ' +
                                                            context
                                                                .read<
                                                                    AddedproductsProvider>()
                                                                .buttonState
                                                                .toString());
                                                      }
                                                    }

                                                    return SubProductsViewPost(
                                                      buttonState: context
                                                          .watch<
                                                              AddedproductsProvider>()
                                                          .buttonState,
                                                      quantity: context
                                                          .watch<
                                                              AddedproductsProvider>()
                                                          .quantity,
                                                      productname: productname,
                                                      offerprice: unitList
                                                          .offerprice
                                                          .toString(),
                                                      unitId: unitList.id
                                                          .toString(),
                                                      type: type,
                                                      shopId: shopId,
                                                      productId:
                                                          unitList.productId,
                                                      name: unitList.name,
                                                      price: unitList.price
                                                          .toString(),
                                                      status: unitList.status,
                                                    );
                                                  })),
                                            );
                                          }));
                            } else {
                              ShowSnackBar(
                                  'Product added to cart.', 2, context);
                              context
                                  .read<CartNotifyProvider>()
                                  .getCartnotification();
                              var response = await CartApi.addToCart(
                                  type, productId, shopId, unitId, context);
                              currentButton.value = true;
                              if (response == true) {
                                // context.read<CartNotifyProvider>().addCount();
                                context.read<TotalAmount>().GetAllAmounts();
                                print(
                                    'add to cart:::::::' + response.toString());
                              }

                              print('add to cart');
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
                                    if (name == i['productname']) {
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
                                      if (response == true) {
                                        print('index ::: ' + i.toString());
                                      }
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
                                      borderRadius: BorderRadius.circular(100),
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
                                  List data = dcartBody['cart'];

                                  for (var i in data) {
                                    print("${name} :::: ${i['productname']}");
                                    print(name == i['productname']);
                                    if (name == i['productname']) {
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

                                      if (response == true) {
                                        // HiveCartRepo.editHiveCart()
                                        print('index ::: ' + i.toString());
                                      }
                                      print(response);
                                      print('cartindex ::: ' +
                                          (data.indexOf(i)).toString());
                                    }
                                  }
                                },
                                child: Container(
                                    width: 15.w,
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Icon(Icons.add,
                                        color: Colors.white, size: 15))),
                          ])),
                ],
              ),
            ),
          ],
        ));
  }
}

//sub posts
class SubProductsViewPost extends HookWidget {
  bool? buttonState;
  int? quantity;
  dynamic unitId;
  String? type;
  dynamic shopId;
  dynamic productId;
  int? itemCount;
  String? image;
  String? productname;
  String name;
  String price;
  String offerprice;
  String status;
  SubProductsViewPost(
      {Key? key,
      this.buttonState,
      this.quantity,
      this.unitId,
      this.type,
      this.shopId,
      this.productId,
      this.itemCount,
      this.image,
      required this.offerprice,
      required this.price,
      required this.productname,
      required this.name,
      required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentButton = useState(buttonState);
    final currentNumber = useState(quantity);
    // final currentNumber = useState(0);
    return Container(
        // padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.only(bottom: 15),
        // height: 100.h,
        width: 350.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 2.w)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 15.w),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 5.h),
                  Text("₹$price", style: TextStyle(fontSize: 12.sp)),
                  SizedBox(height: 5.h),
                  Text(status == "Enabled" ? "Available" : "Not-available",
                      style: TextStyle(
                          fontSize: 12.sp,
                          color:
                              status == "Enabled" ? Colors.green : Colors.red)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  currentButton.value == false
                      ? GestureDetector(
                          onTap: () async {
                            context
                                .read<CartNotifyProvider>()
                                .getCartnotification();
                            context
                                .read<AddedproductsProvider>()
                                .addProductId(unitId);
                            var response = await CartApi.addToCart(
                                type, productId, shopId, unitId, context);
                            if (response == true) {
                              ShowSnackBar('Product added to cart', 2, context);
                              currentButton.value = true;
                              // context.read<CartNotifyProvider>().addCount();
                              context.read<TotalAmount>().GetAllAmounts();
                              print('add to cart:::::::' + response.toString());
                            }

                            print('add to cart');
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
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                    onTap: () async {
                                      print('minus');
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      var cart = prefs.getString('cart');
                                      var cartBody = jsonDecode(cart!);
                                      var dcartBody = jsonDecode(cartBody);

                                      for (var i in dcartBody['cart']) {
                                        if (unitId.toString() ==
                                            i['unit_id'].toString()) {
                                          context
                                              .read<TotalAmount>()
                                              .GetAllAmounts();
                                          currentNumber.value =
                                              currentNumber.value! - 1;
                                          if (currentNumber.value! <= 0)
                                            currentNumber.value = 1;

                                          var response =
                                              await CartApi.updateCart(
                                                  i['id'].toString(),
                                                  currentNumber.value
                                                      .toString(),
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
                                        print("${unitId} :::: ${i['unit_id']}");
                                        print(unitId == i['unit_id']);
                                        if (unitId.toString() ==
                                            i['unit_id'].toString()) {
                                          context
                                              .read<TotalAmount>()
                                              .GetAllAmounts();
                                          currentNumber.value =
                                              currentNumber.value! + 1;
                                          if (currentNumber.value! >= 10)
                                            currentNumber.value = 10;
                                          var response =
                                              await CartApi.updateCart(
                                                  i['id'].toString(),
                                                  currentNumber.value
                                                      .toString(),
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
            ),
          ],
        ));
  }
}

//calculate quantity widget
class CaculateQauntityWidget extends HookWidget {
  String? productId;
  CaculateQauntityWidget({Key? key, this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentNumber = useState(0);
    return Container(
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 2)),
        child: FutureBuilder(
          future: CartApi.getCart(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              CartModal data = snapshot.data;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(data.cart!.length, (index) {
                  final cartList = data.cart![index];
                  currentNumber.value = cartList.quantity ?? 1;
                  // print('currentNumber ' + currentNumber.value.toString());
                  print(productId);
                  print(cartList.productId);
                  print('check product id exist:::::' +
                      (productId.toString() == cartList.productId.toString())
                          .toString());
                  if (productId.toString() == cartList.productId.toString()) {
                    return Row(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              print('minus');
                              // context.read<TotalAmount>().GetAllAmounts();
                              currentNumber.value = currentNumber.value - 1;
                              if (currentNumber.value <= 0)
                                currentNumber.value = 1;

                              var response = await CartApi.updateCart(
                                  cartList.id.toString(),
                                  currentNumber.value.toString(),
                                  context);
                              print(response);
                            },
                            child: Container(
                                // padding: const EdgeInsets.symmetric(horizontal: 1),
                                width: 15.w,
                                height: 15.h,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.white,
                                ))),
                        SizedBox(width: 10),
                        Text("${cartList.quantity}"), //quantity
                        SizedBox(width: 10),
                        GestureDetector(
                            onTap: () async {
                              print('add');
                              // context.read<TotalAmount>().GetAllAmounts();
                              currentNumber.value = currentNumber.value + 1;
                              if (currentNumber.value >= 10)
                                currentNumber.value = 10;
                              var response = await CartApi.updateCart(
                                  cartList.id.toString(),
                                  currentNumber.value.toString(),
                                  context);
                              print(response);
                            },
                            child: Container(
                                width: 15.w,
                                height: 15.h,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Icon(Icons.add,
                                    color: Colors.white, size: 15)))
                      ],
                    );
                  } else {
                    return SizedBox();
                  }
                }),
                // [
                //   GestureDetector(
                //       onTap: () async {
                //         // context.read<TotalAmount>().GetAllAmounts();
                //         // currentNumber.value = currentNumber.value - 1;
                //         // if (currentNumber.value <= 0) currentNumber.value = 1;
                //
                //         // var response = await CartApi.updateCart(
                //         //     cartId.toString(), currentNumber.value.toString());
                //         // if (response == true) {
                //         //   Navigator.pop(context);
                //         //   Navigator.pushNamed(context, '/cart');
                //         // }
                //         // print(response);
                //       },
                //       child: Container(
                //           // padding: const EdgeInsets.symmetric(horizontal: 1),
                //           width: 15.w,
                //           height: 15.h,
                //           padding: const EdgeInsets.all(3),
                //           decoration: BoxDecoration(
                //             color: Colors.black,
                //             borderRadius:
                //                 BorderRadius.circular(100),
                //           ),
                //           child: Divider(
                //             thickness: 2,
                //             color: Colors.white,
                //           ))),
                //   SizedBox(width: 10),
                //   Text("${data.cart.length}"), //quantity
                //   SizedBox(width: 10),
                //   GestureDetector(
                //       onTap: () async {
                //         // context.read<TotalAmount>().GetAllAmounts();
                //         // currentNumber.value = currentNumber.value + 1;
                //         // if (currentNumber.value >= 10) currentNumber.value = 10;
                //         // var response = await CartApi.updateCart(
                //         //     cartId.toString(), currentNumber.value.toString());
                //         // print(response);
                //         // if (response == true) {
                //         //   Navigator.pop(context);
                //         //   Navigator.pushNamed(context, '/cart');
                //         // }
                //       },
                //       child: Container(
                //           width: 15.w,
                //           height: 15.h,
                //           decoration: BoxDecoration(
                //             color: Colors.black,
                //             borderRadius:
                //                 BorderRadius.circular(100),
                //           ),
                //           child: Icon(Icons.add,
                //               color: Colors.white, size: 15)))
                // ],
              );
            } else {
              return Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  margin: const EdgeInsets.only(right: 5),
                  width: 50.w,
                  height: 15.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    // border: Border.all(
                    //     color: Colors.grey.shade300,
                    //     width: 2)
                  ),
                ),
              );
            }
          },
        ));
  }
}
