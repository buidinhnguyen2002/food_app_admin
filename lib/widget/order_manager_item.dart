import 'package:final_project_admin/screens/order_detail_screen.dart';
import 'package:final_project_admin/utils/colors.dart';
import 'package:flutter/material.dart';

class OrderManagerItem extends StatelessWidget {
  const OrderManagerItem(
      {super.key,
      required this.title,
      required this.orderTime,
      required this.totalAmount,
      required this.id,
      required this.status});
  final String id;
  final String title;
  final String orderTime;
  final double totalAmount;
  final String status;
  Color getColor(BuildContext context, String status) {
    Color result = Theme.of(context).colorScheme.primary;
    switch (status) {
      // case 'active':
      //   result = AppColors.blue;
      //   break;
      case 'completed':
        result = Theme.of(context).colorScheme.primary;
        break;
      case 'cancelled':
        result = Theme.of(context).colorScheme.error;
        break;
      default:
        result = AppColors.blue;
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Color colorId = getColor(context, status);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            OrderDetailScreen.routeName,
            arguments: {"id": id},
          );
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(0),
            leading: CircleAvatar(
              backgroundColor: colorId,
              radius: 30,
              child: Text(
                '#$id',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            title: Text(title),
            subtitle: Text(
              orderTime,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            trailing: Text(
              "${totalAmount.toInt()} VNĐ",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}

// IconButton.filled(
//   onPressed: () {},
//   icon: Icon(
//     Icons.check,
//     color: Theme.of(context).colorScheme.primary,
//   ),
//   style: IconButton.styleFrom(
//       backgroundColor:
//           Theme.of(context).colorScheme.primaryContainer),
// ),
// IconButton.filled(
//   onPressed: () {},
//   icon: Icon(
//     Icons.close,
//     color: Theme.of(context).colorScheme.error,
//   ),
//   style: IconButton.styleFrom(
//     backgroundColor: Theme.of(context).colorScheme.errorContainer,
//   ),
// ),
