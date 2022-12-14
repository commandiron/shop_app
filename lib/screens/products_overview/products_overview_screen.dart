import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/app_drawer.dart';
import 'package:shop_app/screens/cart/cart_screen.dart';
import 'package:shop_app/screens/products_overview/widgets/badge.dart';
import 'package:shop_app/screens/products_overview/widgets/products_grid.dart';

import '../../providers/cart.dart';
import '../../providers/product.dart';
import '../../providers/products.dart';

enum FilterOptions {
  Favorites,
  All
}

class ProductsOverviewScreen extends StatefulWidget {

  static const routeName = '/products-overview';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {

  var _showOnlyFavorites = false;
  var _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1)).then((_) {
      Provider.of<Products>(context, listen: false).fetchAndSetProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Shop"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              setState(() {
                if(value == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Only Favorites"),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.All,
              )
            ]
          ),
          Consumer<Cart>(
            builder: (_, cart, child) => Badge(
                child: child,
                value: cart.itemCount.toString()
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(),)
          : ProductsGrid(_showOnlyFavorites, productsData.favoriteItems, productsData.items)
    );
  }
}
