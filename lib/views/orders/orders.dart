import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fresh4delivery/models/order_list_model.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/views/cart/cart.dart';
import 'package:fresh4delivery/views/notification/notification.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:shimmer/shimmer.dart';

class Orders extends StatefulWidget {
  static const routeName = '/orders';
  const Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  var currentPage = 1;
  List errorWidget = [Image.asset('assets/images/empty.png'), OrderShimmer()];

  @override
  void dispose() {
    super.dispose();
  }

  Future loadOrders() async {
    Future.delayed(Duration(seconds: 3), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: loadOrders,
      child: FutureBuilder(
        future: OrderApi.allOrder(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            print('snapshot');
            print(snapshot.data);
            OrderListModel data = snapshot.data;
            return ListView.builder(
                itemCount: data.orders.length,
                itemBuilder: ((context, index) {
                  final orders = data.orders[index];
                  return Container(
                      margin: const EdgeInsets.only(
                          top: 5, left: 20, right: 20, bottom: 5),
                      width: 300.w,
                      // height: 100.h,
                      // constraints: BoxC,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.grey.shade200, width: 2.w)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl:
                                    "https://ebshosting.co.in/${orders.shop?.logo}",
                                placeholder: (context, string) {
                                  return Image.asset('assets/images/empty.png',
                                      fit: BoxFit.cover, height: 80.h);
                                },
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/images/empty.png',
                                        fit: BoxFit.cover, height: 80.h),
                              ),
                            ),
                            // Image.network(
                            //   "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png"
                            //   // 'https://ebshosting.co.in/${orders.shop?.logo}'
                            //   ,
                            //   fit: BoxFit.contain,
                            //   width: 60,
                            //   height: 60,
                            // ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(orders.shop!.name ?? '',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600)),
                                SizedBox(height: 5.h),
                                Text(orders.shop!.deliveryTime ?? '',
                                    style: TextStyle(fontSize: 10.sp)),
                                SizedBox(height: 5.h),
                                Text(orders.status ?? 'pending',
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.red)),
                              ],
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Text("₹${orders.amount ?? 'N/A'}",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600))),
                          orders.status != 'New'
                              ? const SizedBox()
                              : Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 100.h,
                                    // color: Colors.blue,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          'Please Confirm.'),
                                                      content: Text(
                                                          'Are you sure to remove  the order.'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed:
                                                                () async {
                                                              var response =
                                                                  await OrderApi
                                                                      .cancelOrder(
                                                                          orders
                                                                              .id);
                                                              print('order cancelled is ::: ' +
                                                                  response
                                                                      .toString());
                                                              Navigator.pop(
                                                                  context);
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    'Order Canceled.'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                              ));
                                                              print("close");
                                                              // }
                                                            },
                                                            child: Text('Yes')),
                                                        TextButton(
                                                            onPressed: () {},
                                                            child: Text('No')),
                                                      ],
                                                    );
                                                  });
                                            },
                                            icon: Icon(Icons.cancel_rounded,
                                                size: 20,
                                                color: Colors.grey.shade800)),
                                      ],
                                    ),
                                  ),
                                )
                        ],
                      ));
                }));
          } else {
            Future.delayed(Duration(seconds: 5), () {
              setState(() {
                currentPage = 0;
              });
            });
            return Center(child: errorWidget[currentPage]);
          }
        },
      ),
    ));
  }
}

class OrderShimmer extends StatelessWidget {
  const OrderShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 7,
        itemBuilder: ((context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Container(
                margin: const EdgeInsets.only(
                    top: 5, left: 20, right: 20, bottom: 5),
                width: 300.w,
                // height: 100.h,
                // constraints: BoxC,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.grey.shade200, width: 2.w)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: "https://ebshosting.co.in/",
                          placeholder: (context, string) {
                            return Image.asset('assets/images/empty.png',
                                fit: BoxFit.cover, height: 100.h);
                          },
                          errorWidget: (context, url, error) => Image.asset(
                              'assets/images/empty.png',
                              fit: BoxFit.cover,
                              height: 100.h),
                        ),
                      ),
                      // Image.network(
                      //   "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png"
                      //   // 'https://ebshosting.co.in/${orders.shop?.logo}'
                      //   ,
                      //   fit: BoxFit.contain,
                      //   width: 60,
                      //   height: 60,
                      // ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('*******',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 5.h),
                          Text('*********', style: TextStyle(fontSize: 10.sp)),
                          SizedBox(height: 5.h),
                          Text('*******',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.red)),
                        ],
                      ),
                    ),
                    const Expanded(
                        flex: 2,
                        child: Text("₹'N/A'}",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600))),
                  ],
                )),
          );
        }));
  }
}
