import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fresh4delivery/models/res_model.dart';
import 'package:fresh4delivery/models/restaurant_category_modal.dart';
import 'package:fresh4delivery/provider/general_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/utils/star_rating.dart';
import 'package:fresh4delivery/views/home/home.dart';
import 'package:fresh4delivery/views/notification/notification.dart';
import 'package:fresh4delivery/views/orders/orders.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:provider/provider.dart';

class RestuarantsViewMore extends StatelessWidget {
  static const routeName = '/restaurantsviewmore';
  List errorWidget = [Image.asset('assets/images/empty.png'), OrderShimmer()];
  RestuarantsViewMore({Key? key}) : super(key: key);

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
          title: Image.asset("assets/icons/logo1.png", width: 70.w),
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
                            "Restaurants List",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // Image.asset("assets/icons/filter.png")
                        ],
                      ))
                ],
              ),
              preferredSize: Size.fromHeight(80.h))),
      body: FutureBuilder(
          future: RestaurantApi.viewAll(),
          builder: ((context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<Nrestaurants> data = snapshot.data;
              return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: ((context, index) {
                    Nrestaurants products = data[index];
                    print(products.id);
                    return GestureDetector(
                      onTap: () {
                        if (products.status == true) {
                          Navigator.pushNamed(context, '/restuarant-view-post',
                              arguments: products.id.toString());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'This restaurant is currently unAvailable.'),
                            duration: Duration(seconds: 1),
                          ));
                        }
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
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  fit: BoxFit.contain,
                                  width: 100,
                                  // height: 50,
                                  imageUrl:
                                      "https://ebshosting.co.in${products.logo}",
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    'assets/images/empty.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: Text(products.name.toString(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                      products.status == true
                                          ? 'Available'
                                          : 'Not available',
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: products.status == true
                                              ? Colors.green
                                              : Colors.red)),
                                  SizedBox(height: 3.h),
                                  StarRating(
                                    iconsize: 12,
                                    rating: products.rating ?? 0,
                                  )
                                ],
                              ),
                            ],
                          )),
                    );
                  }));
            } else {
              context.read<GeneralProvider>().getNextPage(1);
              Future.delayed(Duration(seconds: 3), () {
                context.watch<GeneralProvider>().getNextPage(0);
              });
              return Center(
                child:
                    errorWidget[context.watch<GeneralProvider>().currentPage],
              );
            }
          })),
    );
  }
}
