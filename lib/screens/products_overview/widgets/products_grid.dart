import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/product.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {

  final bool showOnlyFavorites;
  final List<Product> favoriteItems;
  final List<Product> items;

  ProductsGrid(this.showOnlyFavorites, this.favoriteItems, this.items);

  @override
  Widget build(BuildContext context) {

    final products = showOnlyFavorites
        ? favoriteItems
        : items;

    return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        itemBuilder: (context, index) => ChangeNotifierProvider<Product>.value(
          child: ProductItem(),
          value: products[index],
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
    );
  }
}
