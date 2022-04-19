import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fresh4delivery/models/restaurant_category_modal.dart';
import 'package:fresh4delivery/provider/added_products_provider.dart';
import 'package:fresh4delivery/provider/cart_notify_provider.dart';
import 'package:fresh4delivery/provider/total_amount_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/utils/pop_up_message.dart';
import 'package:fresh4delivery/utils/showSnackBar.dart';
import 'package:fresh4delivery/views/home/home.dart';
import 'package:fresh4delivery/views/notification/notification.dart';
import 'package:fresh4delivery/views/orders/orders.dart';
import 'package:fresh4delivery/views/view_post/resturant_view_post.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewAll extends StatefulWidget {
  static const routeName = '/viewall';
  ViewAll({Key? key}) : super(key: key);

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  var currentPage = 1;
  List errorWidget = [Image.asset('assets/images/empty.png'), OrderShimmer()];

  Future loadViewAll() async {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var arguments = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: AppBar(
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
          title: Image.asset("assets/icons/logo1.png", width: 60.w),
          actions: [
            SizedBox(
                width: 45,
                child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                    child: SvgPicture.asset('assets/icons/cart.svg'))),
          ],
          bottom: PreferredSize(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back)),
                      SearchButton(width: 320.w)
                    ],
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          left: 40, top: 5, bottom: 5, right: 30),
                      width: double.infinity,
                      color: Color.fromRGBO(201, 228, 125, 1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Category List",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // Image.asset("assets/icons/filter.png")
                        ],
                      ))
                ],
              ),
              preferredSize: Size.fromHeight(80.h))),
      body: RefreshIndicator(
        onRefresh: loadViewAll,
        child: FutureBuilder(
            future: RestaurantApi.restaurantCategory(arguments),
            builder: ((context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<ProductModal> data = snapshot.data;
                if (data.length != 0) {
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: ((context, index) {
                        ProductModal products = data[index];
                        //////////////////////
                        List cartList =
                            context.watch<AddedproductsProvider>().cartList;

                        context.read<AddedproductsProvider>().addState(false);

                        for (var i in cartList) {
                          if (products.id.toString() ==
                              i['product_id'].toString()) {
                            context
                                .read<AddedproductsProvider>()
                                .getQuantity(i['quantity']);
                            context
                                .read<AddedproductsProvider>()
                                .addState(true);
                            print('${products.id} ::: ${i}');
                            print('button state ::: ' +
                                context
                                    .read<AddedproductsProvider>()
                                    .buttonState
                                    .toString());
                          }
                        }
                        return Container(
                            margin: const EdgeInsets.only(
                                top: 15, left: 20, right: 20),
                            width: 300.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.shade200, width: 2.w)),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      width: 50,
                                      imageUrl:
                                          "https://ebshosting.co.in${products.image}",
                                      placeholder: (context, string) {
                                        return Image.asset(
                                            'assets/images/empty.png',
                                            fit: BoxFit.cover,
                                            width: 50);
                                      },
                                      errorWidget: (context, url, error) =>
                                          Image.asset('assets/images/empty.png',
                                              fit: BoxFit.cover, width: 50),
                                    ),
                                  ),
                                ),
                                // Image.network(
                                //   products.image.toString().isEmpty ||
                                //           products.image == null
                                //       ? "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png"
                                //       : "https://ebshosting.co.in${products.image}",
                                //   fit: BoxFit.cover,
                                // ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(products.name.toString(),
                                            style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(products.status.toString(),
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color:
                                                  products.status == 'Available'
                                                      ? Colors.green
                                                      : Colors.red)),
                                      SizedBox(height: 5.h),
                                      // StarRating(
                                      //   rating: resturants.rating!.toDouble(),
                                      // )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: AddToCartButton(
                                    buttonState: context
                                        .watch<AddedproductsProvider>()
                                        .buttonState,
                                    quantity: context
                                        .watch<AddedproductsProvider>()
                                        .quantity,
                                    offerprice: products.offerprice.toString(),
                                    status: products.status,
                                    title: products.name,
                                    price: products.offerprice.toString(),
                                    image: products.image,
                                    hasUnit: products.hasUnits,
                                    unit: products.units,
                                    type: products.shopType.toString(),
                                    productId: products.id,
                                    shopId: products.shopId,
                                  ),
                                )
                              ],
                            ));
                      }));
                } else {
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      currentPage = 0;
                    });
                  });
                  return Center(
                    child: errorWidget[currentPage],
                  );
                }
              } else {
                Future.delayed(Duration(seconds: 3), () {
                  setState(() {
                    currentPage = 0;
                  });
                });
                return Center(
                  child: errorWidget[currentPage],
                );
              }
            })),
      ),
    );
  }
}

class AddToCartButton extends HookWidget {
  bool? buttonState;
  int? quantity;
  String? status;
  String? title;
  String? offerprice;
  String? price;
  String? image;
  List? unit;
  String? type;
  dynamic hasUnit;
  dynamic shopId;
  dynamic productId;
  AddToCartButton(
      {Key? key,
      this.quantity,
      this.buttonState,
      this.offerprice,
      this.image,
      this.status,
      this.price,
      this.title,
      this.hasUnit,
      this.type,
      this.unit,
      this.shopId,
      this.productId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentNumber = useState(quantity);
    final currentButton = useState(buttonState);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        currentButton.value == false
            ? GestureDetector(
                onTap: () async {
                  if (status.toString() == false.toString()) {
                    ShowSnackBar(
                        "This product is not currently available.", 2, context);
                  } else {
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
                          builder: (context) => DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: .35,
                              minChildSize: 0.35,
                              maxChildSize: 0.35,
                              builder: (BuildContext context,
                                  ScrollController scrollController) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 20),
                                  child: ListView.builder(
                                      itemCount: unit!.length,
                                      itemBuilder: ((context, index) {
                                        Unit unitList = unit![index];
                                        print(unitList.id);
                                        //////////////////////
                                        List cartList = context
                                            .watch<AddedproductsProvider>()
                                            .cartList;

                                        context
                                            .read<AddedproductsProvider>()
                                            .addState(false);

                                        for (var i in cartList) {
                                          print(
                                              'cart list provider items ::: ' +
                                                  i.toString());
                                          if (unitList.id.toString() ==
                                              i['unit_id'].toString()) {
                                            context
                                                .read<AddedproductsProvider>()
                                                .getQuantity(i['quantity']);
                                            context
                                                .read<AddedproductsProvider>()
                                                .addState(true);
                                            print('${unitList.id} ::: ${i}');
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
                                              .watch<AddedproductsProvider>()
                                              .buttonState,
                                          quantity: context
                                              .watch<AddedproductsProvider>()
                                              .quantity,
                                          productname: title,
                                          offerprice:
                                              unitList.offerprice.toString(),
                                          unitId: unitList.id.toString(),
                                          type: type,
                                          shopId: shopId,
                                          productId: unitList.productId,
                                          name: unitList.name.toString(),
                                          price: unitList.price.toString(),
                                          status: unitList.status.toString(),
                                        );
                                      })),
                                );
                              }));
                    } else {
                      ShowSnackBar(
                          'Product is being added to cart', 2, context);
                      currentButton.value = true;
                      var response = await CartApi.addToCart(
                          type, productId, shopId, 0, context);
                      if (response == true) {
                        ShowSnackBar('Product added to cart', 2, context);
                        // context.read<CartNotifyProvider>().addCount();
                        context.read<TotalAmount>().GetAllAmounts();
                      }
                      print('add to cart:::::::' + response.toString());

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 2)),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            print('minus');
                            final prefs = await SharedPreferences.getInstance();
                            var cart = prefs.getString('cart');
                            var cartBody = jsonDecode(cart!);
                            var dcartBody = jsonDecode(cartBody);

                            for (var i in dcartBody['cart']) {
                              if (title.toString() ==
                                  i['productname'].toString()) {
                                context.read<TotalAmount>().GetAllAmounts();
                                currentNumber.value = currentNumber.value! - 1;
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
                            final prefs = await SharedPreferences.getInstance();
                            var cart = prefs.getString('cart');
                            var cartBody = jsonDecode(cart!);
                            var dcartBody = jsonDecode(cartBody);

                            for (var i in dcartBody['cart']) {
                              print("${title} :::: ${i['productname']}");
                              print(title == i['productname']);
                              if (title.toString() ==
                                  i['productname'].toString()) {
                                context.read<TotalAmount>().GetAllAmounts();
                                currentNumber.value = currentNumber.value! + 1;
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
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(Icons.add,
                                  color: Colors.white, size: 15))),
                    ])),
      ],
    );
  }
}
