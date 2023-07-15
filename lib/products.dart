// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class Products with ChangeNotifier {
  List<Product> productsList = [];

  late final String? authToken;

  getData(String authTok, List<Product> prodcts) {
    authToken = authTok;
    productsList = prodcts;
    notifyListeners();
  }

  Future<void> fetchData() async {
    final url =
        "https://flutter-app-568d3.firebaseio.com/product.json?auth=$authToken";
    try {
      http.Response res = await http.get(Uri.parse(url));
      final extracteData = json.decode(res.body) as Map<String, dynamic>;

      extracteData.forEach(
        (prodId, prodData) {
          final proIndex =
              productsList.indexWhere((element) => element.id == prodId);

          if (proIndex >= 0) {
            // if element exists ,will update element
            productsList[proIndex] = Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              price: prodData['price'],
              imageUrl: prodData['imageUrl'],
            );
          } else {
            // if element doesn't exist ,will add element
            productsList.add(
              Product(
                id: prodId,
                title: prodData['title'],
                description: prodData['description'],
                price: prodData['price'],
                imageUrl: prodData['imageUrl'],
              ),
            );
          }
        },
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateData(String id) async {
    final url = "https://flutter-app-568d3.firebaseio.com/$id.json";
    final prodIndex = productsList.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      await http.patch(Uri.parse(url),
          body: json.encode({
            "title": "new titel",
            "description": "new description",
            "price": "new price",
            "imageUrl":
                "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/12d51b05-ded5-42c6-b59f-96a5b0c24138/d1k7zi5-41d66122-59de-481b-820d-c1c2d0485d8f.jpg/v1/fill/w_600,h_890,q_75,strp/kangaroo_with_joey_by_mym8rick.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi8xMmQ1MWIwNS1kZWQ1LTQyYzYtYjU5Zi05NmE1YjBjMjQxMzgvZDFrN3ppNS00MWQ2NjEyMi01OWRlLTQ4MWItODIwZC1jMWMyZDA0ODVkOGYuanBnIiwid2lkdGgiOiI8PTYwMCIsImhlaWdodCI6Ijw9ODkwIn1dXX0.HnuhJxKeRB2IUKSu-IXtKvMvp1B-Yx9KXh3jzEN3Qbg",
          }));

      productsList[prodIndex] = Product(
        id: id,
        title: "new titel 4",
        description: "new description 2",
        price: 199.8,
        imageUrl:
            "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/12d51b05-ded5-42c6-b59f-96a5b0c24138/d1k7zi5-41d66122-59de-481b-820d-c1c2d0485d8f.jpg/v1/fill/w_600,h_890,q_75,strp/kangaroo_with_joey_by_mym8rick.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi8xMmQ1MWIwNS1kZWQ1LTQyYzYtYjU5Zi05NmE1YjBjMjQxMzgvZDFrN3ppNS00MWQ2NjEyMi01OWRlLTQ4MWItODIwZC1jMWMyZDA0ODVkOGYuanBnIiwid2lkdGgiOiI8PTYwMCIsImhlaWdodCI6Ijw9ODkwIn1dXX0.HnuhJxKeRB2IUKSu-IXtKvMvp1B-Yx9KXh3jzEN3Qbg",
      );
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> add(
      {required String id,
      required String title,
      required String description,
      required double price,
      required String imageUrl}) async {
    const url = "https://flutter-app-568d3.firebaseio.com/product.json";
    try {
      http.Response res = await http.post(Uri.parse(url),
          body: json.encode({
            "id": id,
            "title": title,
            "description": description,
            "price": price,
            "imageUrl": imageUrl,
          }));
      print(json.decode(res.body));

      productsList.add(Product(
        id: json.decode(res.body)['name'],
        title: title,
        description: description,
        price: price,
        imageUrl: imageUrl,
      ));
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> delete(String id) async {
    final url = "https://flutter-app-568d3.firebaseio.com/$id.json";

    // delete in app
    final prodIndex = productsList.indexWhere((element) => element.id == id);
    Product? prodItem = productsList[prodIndex];
    productsList.removeAt(prodIndex);
    notifyListeners();

    // delete in api

    var res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      // if it happened error
      productsList.insert(prodIndex, prodItem);
      notifyListeners();
      print('Could not deleted item');
    } else {
      prodItem = null;
      print(' item deleted ');
    }
  }
}
