import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product/edit_product_screen.dart';
import 'package:shop_app/screens/product_detail/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview/products_overview_screen.dart';
import 'package:shop_app/screens/user_products/user_products_screen.dart';

import 'providers/auth.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => Auth()
        ),
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
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: "Lato" //Anton Lato
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductsOverviewScreen.routeName : (context) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName : (context) => ProductDetailScreen(),
            CartScreen.routeName : (context) => CartScreen(),
            OrdersScreen.routeName : (context) => OrdersScreen(),
            UserProductsScreen.routeName : (context) => UserProductsScreen(),
            EditProductScreen.routeName : (context) => EditProductScreen(),
            AuthScreen.routeName : (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
