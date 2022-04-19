import 'package:flutter/cupertino.dart';
import 'package:fresh4delivery/models/cart_modal.dart';

class AddedproductsProvider extends ChangeNotifier {
  List _productId = [];
  bool _buttonState = false;
  int _quantity = 1;
  List _cartList = [];

  bool get buttonState => _buttonState;
  List get prouctId => _productId;
  int get quantity => _quantity;
  List get cartList => _cartList;

  void getCartList(List carts) {
    _cartList = [];
    _cartList = carts;
    notifyListeners();
  }

  void getQuantity(int num) {
    // _quantity = 0;
    _quantity = num;
    notifyListeners();
  }

  void addState(bool state) {
    _buttonState = false;
    _buttonState = state;
    notifyListeners();
  }

  void addProductId(id) {
    _productId.add(id);
    print('added products list ::: ' + _productId.toString());
  }

  void removeProduct(id) {
    _productId.remove(id);
    print('removed products list ::: ' + _productId.toString());
  }
}
