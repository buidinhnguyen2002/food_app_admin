class FoodOrder {
  final String foodOrderId;
  final String foodId;
  final int quantityOrdered;
  final double price;
  final String foodName;

  FoodOrder(
      {required this.foodOrderId,
      required this.foodId,
      required this.quantityOrdered,
      required this.price,
      required this.foodName});
  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    return FoodOrder(
      foodOrderId: json['food_order_id'] ?? '',
      foodId: json['food_id'] ?? '',
      quantityOrdered: int.parse(json['quantity_ordered']) ?? 0,
      price: double.parse(json['price']) ?? 0.0,
      foodName: json['food_name'] ?? '',
    );
  }
}
