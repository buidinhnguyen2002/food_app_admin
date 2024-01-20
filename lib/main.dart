import 'package:final_project_admin/providers/auth.dart';
import 'package:final_project_admin/providers/food_data.dart';
import 'package:final_project_admin/providers/order_provider.dart';
import 'package:final_project_admin/providers/restaurant_provider.dart';
import 'package:final_project_admin/screens/auth_screen.dart';
import 'package:final_project_admin/screens/dashboard_screen.dart';
import 'package:final_project_admin/screens/food_manager_screen.dart';
import 'package:final_project_admin/screens/order_detail_screen.dart';
import 'package:final_project_admin/screens/order_manager_screen.dart';
import 'package:final_project_admin/screens/print_bill_screen.dart';
import 'package:final_project_admin/screens/product_detail_screen.dart';
import 'package:final_project_admin/screens/restaurant_detail_screen.dart';
import 'package:final_project_admin/screens/restaurant_manager_screen.dart';
import 'package:final_project_admin/screens/splash_screen.dart';
import 'package:final_project_admin/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
        ChangeNotifierProvider(create: (ctx) => FoodData()),
        ChangeNotifierProvider(create: (ctx) => RestaurantProvider()),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: 'Food App Admin',
          theme: lightMode,
          home: auth.isAuth ? const SplashScreen() : const AuthScreen(),
          routes: {
            DashboardScreen.routeName: (ctx) => const DashboardScreen(),
            OrderManagerScreen.routeName: (ctx) => const OrderManagerScreen(),
            OrderDetailScreen.routeName: (ctx) => const OrderDetailScreen(),
            FoodManagerScreen.routeName: (ctx) => const FoodManagerScreen(),
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            RestaurantManagerScreen.routeName: (ctx) =>
                const RestaurantManagerScreen(),
            RestaurantDetail.routeName: (ctx) => const RestaurantDetail(),
            PrintBillScreen.routeName: (ctx) => const PrintBillScreen(),
          },
        ),
      ),
    );
  }
}
