import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fresh4delivery/models/home_model.dart';
import 'package:fresh4delivery/models/res_model.dart';
import 'package:fresh4delivery/provider/cart_notify_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/utils/star_rating.dart';
import 'package:fresh4delivery/views/notification/notification.dart';
import 'package:fresh4delivery/views/orders/orders.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:provider/provider.dart';

class NearYou extends StatefulWidget {
  static const routeName = '/near-you';
  const NearYou({
    Key? key,
  }) : super(key: key);

  @override
  State<NearYou> createState() => _NearYouState();
}

class _NearYouState extends State<NearYou> {
  var currentPage = 1;
  List errorWidget = [Image.asset('assets/images/empty.png'), OrderShimmer()];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
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
                      print('notification');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => NotificationScreen()));
                    },
                    child: SvgPicture.asset('assets/icons/notification.svg')),
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
                    context.read<CartNotifyProvider>().count == 0
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
                        child: Text(
                          arguments == true
                              ? 'Restuarants near you'
                              : "Supermarkets near you",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ))
                  ],
                ),
                preferredSize: Size.fromHeight(80.h))),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: FutureBuilder(
              future: arguments == true
                  ? RestaurantApi.viewAll()
                  : SupermarketApi.viewAll(),
              builder: ((context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  return ListView.builder(
                      itemCount: data.length,
                      itemBuilder: ((context, index) {
                        Nrestaurants resturants = data[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context,
                                arguments == true
                                    ? '/restuarant-view-post'
                                    : '/supermarket-view-post',
                                arguments: resturants.id.toString());
                          },
                          child: Container(
                              margin: const EdgeInsets.only(
                                  top: 15, left: 20, right: 20),
                              width: 300.w,
                              height: 100.h,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.grey.shade200, width: 2.w)),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          "https://ebshosting.co.in${resturants.logo}",
                                      placeholder: (context, string) {
                                        return Image.asset(
                                            'assets/images/empty.png',
                                            width: 100.h,
                                            fit: BoxFit.cover);
                                      },
                                      errorWidget: (context, url, error) =>
                                          Image.asset('assets/images/empty.png',
                                              width: 100.h, fit: BoxFit.cover),
                                    ),
                                  ),
                                  // Image.network(
                                  //   resturants.logo.toString().isEmpty ||
                                  //           resturants.logo == null
                                  //       ? "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png"
                                  //       : "https://ebshosting.co.in${resturants.logo}",
                                  //   fit: BoxFit.cover,
                                  // ),
                                  SizedBox(width: 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Text(resturants.name.toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                      SizedBox(height: 5.h),
                                      Text(resturants.deliveryTime.toString(),
                                          style: TextStyle(fontSize: 12.sp)),
                                      SizedBox(height: 5.h),
                                      // StarRating(
                                      //   rating: resturants.rating!.toDouble(),
                                      // )
                                    ],
                                  ),
                                ],
                              )),
                        );
                      }));
                } else {
                  Future.delayed(Duration(seconds: 3), () {
                    currentPage = 0;
                  });
                  return Center(child: errorWidget[currentPage]);
                }
              })),
        ));
  }
}
