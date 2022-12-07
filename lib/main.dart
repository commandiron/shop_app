import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product/edit_product_screen.dart';
import 'package:shop_app/screens/product_detail/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
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
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products(null, null, []),
          update: (context, auth, previousProducts) {
            return Products(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items
            );
          },
        ),
        ChangeNotifierProvider(
            create: (context) => Cart()
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders(null, null, []),
          update: (context, auth, previousOrders) => Orders(
              auth.token,
              auth.userId,
              previousOrders == null ? [] : previousOrders.orders
          ),
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
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, authResultSnapshot) =>
                    authResultSnapshot.connectionState == ConnectionState.waiting
                  ? SplashScreen()
                  : AuthScreen(),),
            routes: {
              ProductDetailScreen.routeName : (context) => ProductDetailScreen(),
              CartScreen.routeName : (context) => CartScreen(),
              OrdersScreen.routeName : (context) => OrdersScreen(),
              UserProductsScreen.routeName : (context) => UserProductsScreen(),
              EditProductScreen.routeName : (context) => EditProductScreen()
            }
        ),
      )
    );
  }
}
