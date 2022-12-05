import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/cart.dart';
import '../../../providers/orders.dart';
import '../../orders/orders_screen.dart';

class OrderButton extends StatefulWidget {

  final Cart cart;

  OrderButton(this.cart);

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading) ? null : () async {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
            widget.cart.items.values.toList(),
            widget.cart.totalAmount
        );
        setState(() {
          _isLoading = false;
        });
        widget.cart.clear();
        Navigator.of(context).pushNamed(OrdersScreen.routeName);
      },
      child: _isLoading ? CircularProgressIndicator() : Text("Order Now"),
      style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
              Theme.of(context).primaryTextTheme.titleSmall
          )
      ),
    );
  }
}
