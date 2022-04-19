import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fresh4delivery/models/home_model.dart';
import 'package:fresh4delivery/provider/general_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/views/cart/cart.dart';
import 'package:fresh4delivery/views/notification/notification.dart';
import 'package:fresh4delivery/widgets/search_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Category extends StatefulWidget {
  static const routeName = '/category';
  const Category({Key? key}) : super(key: key);

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  var currentPage = 1;
  List errorWidget = [
    Center(child: Image.asset('assets/images/empty.png')),
    CategoryShimmer()
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      //             Navigator.push(context,
      //                 MaterialPageRoute(builder: (_) => NotificationScreen()));
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
      //             Container(
      //                 padding:
      //                     const EdgeInsets.only(left: 40, top: 5, bottom: 5),
      //                 width: double.infinity,
      //                 color: Color.fromRGBO(201, 228, 125, 1),
      //                 child: Text("all category"))
      //           ],
      //         ),
      //         preferredSize: Size.fromHeight(80.h))),
      body: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: FutureBuilder(
              future: HomeApi.categories(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<CategoryModel> data = snapshot.data;
                  return GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: data.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0),
                      itemBuilder: (context, index) {
                        CategoryModel categories = data[index];
                        return Circlewidget(
                            id: categories.id.toString(),
                            title: categories.name ?? '',
                            image:
                                'https://ebshosting.co.in/${categories.image}');
                      });
                } else {
                  context.read<GeneralProvider>().getNextPage(1);
                  Future.delayed(Duration(seconds: 5), () {
                    context.read<GeneralProvider>().getNextPage(0);
                  });
                  return errorWidget[
                      context.read<GeneralProvider>().currentPage];
                }
              })),
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade200,
        child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: 21,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, mainAxisSpacing: 0, crossAxisSpacing: 0),
            itemBuilder: (context, index) {
              return Circlewidget(
                  id: 'id', title: '', image: 'https://ebshosting.co.in/');
            }));
  }
}

class Circlewidget extends StatelessWidget {
  String? id;
  String image;
  String title;
  Circlewidget(
      {Key? key,
      this.id,
      this.image =
          "https://westsiderc.org/wp-content/uploads/2019/08/Image-Not-Available.png",
      this.title = 'not availabel'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('category-One');
        Navigator.pushNamed(context, '/viewall', arguments: id);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(100),
            ),
            clipBehavior: Clip.hardEdge,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                width: 60,
                height: 60,
                imageUrl: image,
                placeholder: (context, string) {
                  return Image.asset('assets/images/empty.png');
                },
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/empty.png'),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(title,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500))
        ],
      ),
    );
  }
}
