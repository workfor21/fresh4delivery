import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fresh4delivery/config/constants/api_configurations.dart';
import 'package:fresh4delivery/models/address_model.dart';
import 'package:fresh4delivery/provider/address_provider.dart';
import 'package:fresh4delivery/repository/customer_repo.dart';
import 'package:fresh4delivery/views/profile/address/add_new_address.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class YourAddress extends StatefulWidget {
  static const routeName = '/your-address';
  const YourAddress({Key? key}) : super(key: key);

  @override
  State<YourAddress> createState() => _YourAddressState();
}

class _YourAddressState extends State<YourAddress> {
  @override
  Widget build(BuildContext context) {
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
          // automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.black)),
          title: Text("Manage Address",
              style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
        body: RefreshIndicator(onRefresh: refreshScreen, child: AddressBody()));
  }

  Future refreshScreen() async {
    Future.delayed(Duration(seconds: 2));
    setState(() {});
  }
}

class AddressBody extends HookWidget {
  AddressBody({Key? key}) : super(key: key);
  List errorWidget = [
    Image.asset('assets/images/add_address.png'),
    CircularProgressIndicator()
  ];

  @override
  Widget build(BuildContext context) {
    final state = useState(0);
    final currentPage = useState(1);
    return Stack(clipBehavior: Clip.none, children: [
      SizedBox(
          height: MediaQuery.of(context).size.height * .78,
          child: FutureBuilder(
              future: AddressApi.addressList(),
              builder: ((context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<AddressListModel> data = snapshot.data;
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: ((context, index) {
                        AddressListModel addressList = data[index];
                        return GestureDetector(
                          onTap: () async {
                            await AddressApi.defualtAddress(
                                addressList.id.toString());
                            state.value = index;
                          },
                          child: SelectableAddressWidget(
                            defaultAddr: addressList.addressDefault,
                            id: addressList.id.toString(),
                            addresstype: addressList.type ?? '',
                            address: addressList.address ?? '',
                            mobile: addressList.mobile ?? '',
                            phone: addressList.mobile ?? '',
                            pincode: addressList.pincode ?? '',
                            name: addressList.name ?? '',
                            landmark: addressList.landmark ?? '',
                            city: addressList.city ?? '',
                            district: addressList.district.toString(),
                            state: addressList.state.toString(),
                          ),
                        );
                      }));
                } else {
                  Future.delayed(Duration(seconds: 5), () {
                    currentPage.value = 0;
                  });
                  return Center(
                      child: Center(child: errorWidget[currentPage.value]));
                }
              }))),
      Positioned(
        right: 30,
        bottom: -10,
        child: GestureDetector(
          onTap: () {
            print('add');
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddNewAddress()));
          },
          child: Container(
              height: 45.h,
              width: 115.w,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Color.fromRGBO(166, 206, 57, 1),
                        Color.fromRGBO(72, 170, 152, 1)
                      ]),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(
                "Add Address",
                style: TextStyle(color: Colors.white),
              ))),
        ),
      )
    ]);
  }
}

class SelectableAddressWidget extends StatelessWidget {
  dynamic defaultAddr;
  String? id;
  String? addresstype;
  String? address;
  String? phone;
  String? pincode;
  String? mobile;
  String? name;
  String? landmark;
  String? city;
  String? district;
  String? state;

  SelectableAddressWidget(
      {Key? key,
      this.mobile,
      this.state,
      this.landmark,
      this.district,
      this.name,
      this.city,
      this.defaultAddr,
      this.id,
      this.addresstype,
      this.address,
      this.phone,
      this.pincode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 15, left: 20, right: 20),
        width: 300.w,
        height: 100.h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 2.w)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: int.parse(defaultAddr) == 1
                    ? Icon(Icons.radio_button_checked)
                    : Icon(Icons.radio_button_unchecked)),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(addresstype!,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 5.h),
                  Text(address!, style: TextStyle(fontSize: 12.sp)),
                  SizedBox(height: 5.h),
                  Text(phone!, style: TextStyle(fontSize: 12.sp)),
                  SizedBox(height: 5.h),
                  Text(pincode!, style: TextStyle(fontSize: 12.sp)),
                ],
              ),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(width: 1, color: Colors.grey.shade300)),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/update-address',
                          arguments: AddressData(
                              id,
                              name,
                              mobile,
                              phone,
                              pincode,
                              landmark,
                              city,
                              address,
                              district,
                              state,
                              addresstype));
                    },
                    child: Text('Edit',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600)),
                  ),
                )),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () async {
                        var response = await AddressApi.removeAddress(id);
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/your-address');
                        print("remove");
                      },
                      icon: Icon(Icons.cancel_rounded,
                          size: 20, color: Colors.grey.shade800)),
                ],
              ),
            )
          ],
        ));
  }
}

class AddressData {
  String? id;
  String? userId;
  String? addressDefault;
  String? name;
  String? mobile;
  String? phone;
  String? pincode;
  String? landmark;
  String? city;
  String? address;
  String? district;
  String? state;
  String? addresstype;

  AddressData(
      this.id,
      this.name,
      this.mobile,
      this.phone,
      this.pincode,
      this.landmark,
      this.city,
      this.address,
      this.district,
      this.state,
      this.addresstype);
}
