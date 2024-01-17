import 'package:final_project_admin/providers/food_data.dart';
import 'package:final_project_admin/providers/order_provider.dart';
import 'package:final_project_admin/providers/restaurant_provider.dart';
import 'package:final_project_admin/screens/dashboard_screen.dart';
import 'package:final_project_admin/utils/constants.dart';
import 'package:final_project_admin/utils/widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void loadData() async {
    await Provider.of<FoodData>(context, listen: false).fetchAndSetFood();
    await Provider.of<OrderProvider>(context, listen: false).fetchAndSetOrder();
    await Provider.of<OrderProvider>(context, listen: false)
        .fetchAndSetFoodOrder();
    await Provider.of<RestaurantProvider>(context, listen: false)
        .fetchAndSetRestaurant();

    await Future.delayed(
      const Duration(seconds: 2),
      () =>
          Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AssetConstants.logo, fit: BoxFit.cover),
                BoxEmpty.sizeBox10,
                const Text(
                  "Foodu",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: deviceSize.width / 2 - 20,
            child: const CircularProgressIndicator.adaptive(),
          )
        ],
      ),
    );
  }
}
