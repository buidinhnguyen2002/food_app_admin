import 'package:final_project_admin/screens/dashboard_screen.dart';
import 'package:final_project_admin/screens/food_manager_screen.dart';
import 'package:final_project_admin/screens/order_manager_screen.dart';
import 'package:final_project_admin/screens/restaurant_manager_screen.dart';
import 'package:final_project_admin/utils/colors.dart';
import 'package:final_project_admin/utils/functions.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  Widget appDrawerItem(
      BuildContext context, String title, IconData icon, VoidCallback onPress,
      {Color? colorText}) {
    return ListTile(
      leading: Icon(
        icon,
        color: colorText ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(color: colorText ?? AppColors.black),
      ),
      onTap: onPress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      surfaceTintColor: AppColors.white,
      child: Column(
        children: [
          AppBar(
            title: ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: CircleAvatar(
                child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/149/149071.png'),
              ),
              title: const Text(
                "Bùi Đình Nguyên",
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          // const Divider(),
          appDrawerItem(context, "Dashboard", Icons.dashboard, () {
            navigation(context, DashboardScreen.routeName);
          }),
          const Divider(),
          appDrawerItem(context, "Order manager", Icons.shopping_bag, () {
            navigation(context, OrderManagerScreen.routeName);
          }),
          const Divider(),
          appDrawerItem(context, "Food manager", Icons.no_food, () {
            navigation(context, FoodManagerScreen.routeName);
          }),
          const Divider(),
          appDrawerItem(context, "Restaurant manager", Icons.restaurant, () {
            navigation(context, RestaurantManagerScreen.routeName);
          }),
          const Divider(),
          appDrawerItem(
              context, "Account manager", Icons.manage_accounts, () {}),
          const Divider(),
          appDrawerItem(context, "Logout", Icons.logout, () {},
              colorText: AppColors.red),
        ],
      ),
    );
  }
}
