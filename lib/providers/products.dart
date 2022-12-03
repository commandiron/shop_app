import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return items.firstWhere((item) => item.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products.json");

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(
            Product(
              id: prodId,
              title: prodData["title"],
              description: prodData["description"],
              price: prodData["price"],
              isFavorite: prodData["isFavorite"],
              imageUrl: prodData["imageUrl"]
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
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products.json");

    try {
      final response = await http.post(url, body: json.encode({
        "title": product.title,
        "description": product.description,
        "imageUrl": product.imageUrl,
        "price": product.price,
        "isFavorite": product.isFavorite
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
      final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products/${id}.json");
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
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products/${id}.json");

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

  Future<void> toggleFavorite(String id) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if(prodIndex >= 0) {
      final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/products/${id}.json");
      final newProduct = _items[prodIndex];
      try{
        await http.patch(url,body: json.encode({
          "title": newProduct.title,
          "description": newProduct.description,
          "imageUrl": newProduct.imageUrl,
          "price": newProduct.price,
          "isFavorite": !newProduct.isFavorite
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
}