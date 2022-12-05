import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_drawer.dart';
import '../../providers/orders.dart' show Orders;
import 'package:shop_app/screens/orders/widget/order_item.dart';

class OrdersScreen extends StatefulWidget {

  static const routeName = "/orders";

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {

  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Orders"
        ),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (context, dataSnapshot) {
          if(dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          } else {
            if(dataSnapshot.error != null) {
              return Center(child: Text("An error occured."),);
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, child) {
                  return ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (context, index) => OrderItem(
                          orderData.orders[index]
                      )
                  );
                }
              );
            }
          }
        }
      )
    );
  }
}
