import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.date,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    const url = 'https://flutter-shop-app-26fd6.firebaseio.com/orders.json';

    try {
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];

      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      extractedData.forEach((orderId, orderData) {
        print(orderData);
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            date: DateTime.parse(orderData['date']),
            products: (orderData['products'] as List<dynamic>)
                .map((item) { 
                  return CartItem(
                      id: json.decode(item)['id'],
                      price: json.decode(item)['price'],
                      quantity: json.decode(item)['quantity'],
                      title: json.decode(item)['title'],
                    );})
                .toList(),
          ),
        );
      });

      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (e) {
      print('errorrr');
      print(e);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    const url = 'https://flutter-shop-app-26fd6.firebaseio.com/orders.json';
    final timestamp = DateTime.now();

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'date': timestamp.toIso8601String(),
            'products': cartProducts.map((prod) {
              return json.encode({
                'id': prod.id,
                'title': prod.title,
                'quantity': prod.quantity,
                'price': prod.price
              });
            }).toList()
          },
        ),
      );

      OrderItem newOrder = OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        date: timestamp,
        products: cartProducts,
      );

      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (e) {}
  }
}
