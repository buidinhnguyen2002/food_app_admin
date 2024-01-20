import 'dart:convert';
import 'package:final_project_admin/models/food_order.dart';
import 'package:final_project_admin/models/order.dart';
import 'package:final_project_admin/utils/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderProvider with ChangeNotifier {
  List<Order> _myOrder = [];
  int selectedPage = 0;
  int quantityPage = 0;
  List<Order> get myOrder {
    return _myOrder;
  }

  Map<String, String> process = {
    "confirm": "delivery",
    "delivery": "deliver",
    "deliver": "completed"
  };

  List<FoodOrder> _foodOrders = [];
  List<FoodOrder> get foodOrders {
    return _foodOrders;
  }

  double getRevenueMilestone(List<String> restaurantIds) {
    double result;
    // List<double> temp = getRevenueRestaurant(restaurantIds);
    List<double> temp = [];
    restaurantIds.forEach((id) {
      temp.add(getRevenueRestaurantById(id));
    });
    result = temp.reduce((max, current) => max > current ? max : current);
    return result;
  }

  double getRevenueRestaurantById(String id) {
    double sum = _myOrder.where((o) => o.restaurantId == id).toList().fold(
        0, (previousValue, current) => previousValue + current.totalAmount);
    return sum;
  }

  List<double> getRevenueRestaurant(List<String> restaurantIds) {
    List<double> temp = [];
    restaurantIds.forEach((id) {
      temp.add(getRevenueRestaurantById(id));
    });
    return temp;
  }

  List<Order> get activeOrder {
    return _myOrder.where((order) => order.status == 'active').toList();
  }

  List<Order> get cancelOrder {
    return _myOrder.where((order) => order.status == 'cancelled').toList();
  }

  List<Order> get completeOrder {
    return _myOrder.where((order) => order.status == 'completed').toList();
  }

  void changePageOrder(int index) {
    selectedPage = index;
    notifyListeners();
  }

  void incrementPage() {
    if (selectedPage == quantityPage) return;
    selectedPage++;
    notifyListeners();
  }

  void decreaseIndexPage() {
    if (selectedPage == 0) return;
    selectedPage--;
    notifyListeners();
  }

  List<Order> getPageOrder(int page) {
    List<Order> result = [];
    for (int i = page * 10; i < page * 10 + 10; i++) {
      if (_myOrder.length - 1 == i) break;
      result.add(_myOrder[i]);
    }
    return result;
  }

  Order getOrderById(String id) {
    return _myOrder.where((order) => order.id == id).first;
  }

  int getProcessById(String id) {
    int result = 0;
    Order order = getOrderById(id);
    String status = order.status;
    switch (status) {
      case "confirm":
        result = 0;
        break;
      case "delivery":
        result = 1;
        break;
      case "deliver":
        result = 2;
        break;
      case "completed":
        result = 3;
        break;
      default:
    }
    return result;
  }

  Future<void> fetchAndSetFoodOrder() async {
    try {
      final response = await http.get(
        Uri.parse(API.foodOrder),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData['status'] != 'success') return;
      final data = extractedData['data'] as List;
      print(data);
      _foodOrders = data.map((food) => FoodOrder.fromJson(food)).toList();
      notifyListeners();
    } catch (e) {
      print("Loi order provider $e");
    }
  }

  List<FoodOrder> getFoodOrdersById(String orderId) {
    return _foodOrders
        .where((fOrder) => fOrder.foodOrderId == orderId)
        .toList();
  }

  Future<void> fetchAndSetOrder() async {
    try {
      final response = await http.get(
        Uri.parse(API.order),
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData['status'] != 'success') return;
      final data = extractedData['data'] as List;
      print(data);
      _myOrder = data.map((food) => Order.fromJson(food)).toList();
      quantityPage = (_myOrder.length / 10).ceil();
      notifyListeners();
    } catch (e) {
      print("Loi order provider $e");
    }
  }

  Future<void> handleChangeStatusOrder(String orderId) async {
    Order order = getOrderById(orderId);
    final newStatus = process[order.status];
    try {
      final response = await http.patch(
        Uri.parse(API.order),
        body: json.encode({
          'id': orderId,
          // 'status': 'cancelled',
          'status': newStatus,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        fetchAndSetOrder();
        print("Thanh cong");
      }
    } catch (e) {
      print(e);
    }
  }
}
