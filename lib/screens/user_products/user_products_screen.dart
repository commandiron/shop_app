import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/app_drawer.dart';
import 'package:shop_app/screens/edit_product/edit_product_screen.dart';
import 'package:shop_app/screens/user_products/widgets/user_product_item.dart';

import '../../providers/products.dart';

class UserProductsScreen extends StatelessWidget {

  static const routeName = "/user-products";

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your products"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                EditProductScreen.routeName
              );
            },
            icon: Icon(
              Icons.add
            )
          )
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productData.items.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  UserProductItem(
                      productData.items[index].id,
                      productData.items[index].title,
                      productData.items[index].imageUrl
                  ),
                  Divider()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
