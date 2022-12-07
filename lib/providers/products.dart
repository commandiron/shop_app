import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return items.firstWhere((item) => item.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString = filterByUser ? "orderBy=\"creatorId\"&equalTo=\"$userId\"" : "";
    var url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken&$filterString");
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if(extractedData == null) {
        return;
      }
      url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken");
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
              id: prodId,
              title: prodData["title"],
              description: prodData["description"],
              price: prodData["price"],
              isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
              imageUrl: prodData["imageUrl"],
            )
          );
        }
      );
      _items = loadedProducts;
      notifyListeners();
    }catch(error){
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products.json?auth=$authToken");

    try {
      final response = await http.post(url, body: json.encode({
        "title": product.title,
        "description": product.description,
        "imageUrl": product.imageUrl,
        "price": product.price,
        "creatorId" : userId
      }));

      final newProduct = Product(
          id: json.decode(response.body)["name"],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl
      );

      _items.add(newProduct);

      notifyListeners();

    }catch(error){
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if(prodIndex >= 0) {
      final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products/${id}.json?auth=$authToken");
      try{
        await http.patch(url,body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price,
        }));
        _items[prodIndex] = newProduct;
        notifyListeners();
      }catch(error){
        print(error);
        throw error;
      }
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products/${id}.json?auth=$authToken");

    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if(response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product.");
    }
    existingProduct = null;
  }
}