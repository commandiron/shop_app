import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_drawer.dart';
import '../../providers/orders.dart' show Orders;
import 'package:shop_app/screens/orders/widget/order_item.dart';

class OrdersScreen extends StatelessWidget {

  static const routeName = "/orders";

  @override
  Widget build(BuildContext context) {

    final orders = Provider.of<Orders>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Orders"
        ),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderItem(
            orders[index]
          );
        },
      ),
    );
  }
}
