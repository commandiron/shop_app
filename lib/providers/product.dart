import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  void toggleFavoriteStatus(String token, String userId) async {
    final url = Uri.parse("https://my-shop-app-29703-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/${id}.json?auth=$token");
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try{
      final response = await http.put(url, body: json.encode(
        isFavorite
      ));
      if(response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    }catch(error){
      _setFavValue(oldStatus);
    }
  }
}