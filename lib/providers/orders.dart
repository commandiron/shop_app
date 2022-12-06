import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart.dart';
import 'product.dart';
import 'products.dart';



class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime
  });
}

class Orders with ChangeNotifier {

  List<OrderItem> _orders = [];

  final String authToken;

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$authToken");
    try {
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if(extractedData == null) {
        return;
      }

      extractedData.forEach(
        (orderId, orderData) {

          loadedOrders.add(
              OrderItem(
                  id: orderId,
                  amount: orderData["amount"],
                  products: (orderData["products"] as  List<dynamic>).map((item) {
                    return CartItem(
                      id: item["id"],
                      title: item["title"],
                      quantity: item["quantity"],
                      price: item["price"]
                    );
                  }).toList(),
                  dateTime: DateTime.parse(orderData["dateTime"])
              )
          );
        }
      );
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    }catch(error){
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/orders.json?auth=$authToken");
    final timeStamp = DateTime.now();
    final response = await http.post(
        url,
        body: json.encode(
          {
            "amount" : total,
            "dateTime" : timeStamp.toIso8601String(),
            "products" : cartProducts.map((cp) => {
              "id" : cp.id,
              "title" : cp.title,
              "quantity" : cp.quantity,
              "price" : cp.price
            }).toList()
          }
        )
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp
      )
    );
    notifyListeners();
  }
}