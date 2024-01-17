import 'package:final_project_admin/providers/restaurant_provider.dart';
import 'package:final_project_admin/widget/app_drawer.dart';
import 'package:final_project_admin/widget/restaurant_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RestaurantManagerScreen extends StatelessWidget {
  const RestaurantManagerScreen({super.key});
  static const routeName = "/restaurant-manager-screen";

  @override
  Widget build(BuildContext context) {
    final restaurants =
        Provider.of<RestaurantProvider>(context, listen: false).restaurants;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("Restaurant manager",
            style: Theme.of(context).textTheme.titleMedium),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
        child: ListView.builder(
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return RestaurantItem(
              key: ValueKey(restaurant.id),
              id: restaurant.id,
              image: restaurant.image,
              name: restaurant.name,
              description: restaurant.description,
              phoneNumber: restaurant.phoneNumber,
              rate: restaurant.rate,
            );
          },
          itemCount: restaurants.length,
        ),
        // child: Text("ABC"),
      ),
    );
  }
}
