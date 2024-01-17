import 'package:final_project_admin/models/food.dart';
import 'package:final_project_admin/providers/food_data.dart';
import 'package:final_project_admin/utils/widget.dart';
import 'package:final_project_admin/widget/add_food.dart';
import 'package:final_project_admin/widget/app_drawer.dart';
import 'package:final_project_admin/widget/common_button.dart';
import 'package:final_project_admin/widget/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodManagerScreen extends StatelessWidget {
  const FoodManagerScreen({super.key});
  static const routeName = "/food-manager-screen";
  @override
  Widget build(BuildContext context) {
    final foodData = Provider.of<FoodData>(context);
    final foods = foodData.foods;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Food manager"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return ProductItem(
                      id: food.id,
                      image: food.imageSource,
                      price: food.price,
                      title: food.foodName);
                },
                itemCount: foods.length,
              ),
            ),
            BoxEmpty.sizeBox15,
            CommonButton(
                title: "Add new food",
                onPress: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    builder: (context) {
                      return const AddFoodModalBottomSheet();
                    },
                  ).then((value) {
                    if (value == true) {
                      Provider.of<FoodData>(context, listen: false)
                          .fetchAndSetFood();
                    }
                  });
                }),
          ],
        ),
      ),
    );
  }
}
