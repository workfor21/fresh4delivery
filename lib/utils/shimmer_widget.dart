import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fresh4delivery/models/pincode_model.dart';
import 'package:fresh4delivery/provider/pincode_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/views/home/home.dart';
import 'package:fresh4delivery/views/main_screen/main_screen.dart';
import 'package:fresh4delivery/widgets/header.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
                aspectRatio: 10 / 4.5,
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: AssetImage("assets/images/carousal1.png"),
                            fit: BoxFit.cover)),
                  ),
                )),
            SizedBox(height: 20),
            Shimmer.fromColors(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.grey.shade50,
              child: SizedBox(
                height: 90.h,
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: 8,
                    itemBuilder: ((context, index) {
                      return CircleWidget(
                          id: '',
                          title: ' ',
                          image: "https://ebshosting.co.in");
                    })),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset("assets/images/carousal1.png",
                        width: 170.w, height: 100.h, fit: BoxFit.cover),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade200,
                  highlightColor: Colors.grey.shade50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset("assets/images/carousal1.png",
                        width: 170.w, height: 100.h, fit: BoxFit.cover),
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Headerwidget(title: "Top Restaurants")),
            SizedBox(height: 20),
            SizedBox(
              height: 170,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: ((context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Cards(
                        route: '',
                        isRating: false,
                      ),
                    );
                  })),
            ),
            SizedBox(height: 20),
            Shimmer.fromColors(
                baseColor: Colors.grey.shade200,
                highlightColor: Colors.grey.shade50,
                child: Headerwidget(title: "Top Restaurants")),
            SizedBox(height: 20),
            SizedBox(
              height: 170,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: ((context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Cards(
                        route: '',
                        isRating: false,
                      ),
                    );
                  })),
            ),
          ],
        ),
      ),
    );
  }
}

void show(BuildContext context) async {
  final pref = await SharedPreferences.getInstance();
  pref.getString("pincode").toString().isEmpty ||
          pref.getString("pincode") == null
      ? showModalBottomSheet(
          isDismissible: false,
          isScrollControlled: true,
          context: context,
          builder: (context) => WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: .5,
                    minChildSize: 0.5,
                    maxChildSize: 0.5,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Selected pincode",
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Container(
                              height: 65,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20),
                              child: CupertinoSearchTextField(),
                            ),
                            FutureBuilder(
                                future: SearchApi.pincode(),
                                builder: ((context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    List<PincodeModel> data = snapshot.data;
                                    return ListView.builder(
                                        controller: scrollController,
                                        shrinkWrap: true,
                                        itemCount: data.length,
                                        itemBuilder: ((context, index) {
                                          PincodeModel pincodes = data[index];
                                          return GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              Navigator.pushNamed(
                                                  context, '/mainScreen');
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              var pin = prefs.setString(
                                                  "pincode", pincodes.text);
                                              context
                                                  .read<pincodeProvider>()
                                                  .getPincode(pincodes.text);
                                            },
                                            child: Container(
                                                height: 50,
                                                margin: const EdgeInsets.only(
                                                    left: 20,
                                                    right: 20,
                                                    top: 5),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        width: 2,
                                                        color: Colors
                                                            .grey.shade200)),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons
                                                        .location_on_outlined),
                                                    SizedBox(width: 20),
                                                    Text(pincodes.text
                                                        .toString()),
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
                    }),
              ))
      : null;
}
