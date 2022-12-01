import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/product_detail/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview/products_overview_screen.dart';

import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Products()
        ),
        ChangeNotifierProvider(
            create: (context) => Cart()
        ),
        ChangeNotifierProvider(
            create: (context) => Orders()
        ),
      ],
      child: MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.deepOrange,
          fontFamily: "Lato" //Anton Lato
        ),
        home: ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.routeName : (context) => ProductDetailScreen(),
          CartScreen.routeName : (context) => CartScreen(),
          OrdersScreen.routeName : (context) => OrdersScreen()
        },
      ),
    );
  }
}
