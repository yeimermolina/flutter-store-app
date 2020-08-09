import 'package:flutter/foundation.dart';
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

  void addOrder(List<CartItem> cartProducts, double total) {
    OrderItem newOrder = OrderItem(
      id: DateTime.now().toString(),
      amount: total,
      date: DateTime.now(),
      products: cartProducts,
    );
    
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}
