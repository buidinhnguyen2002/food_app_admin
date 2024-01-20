import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:final_project_admin/models/food_order.dart';
import 'package:final_project_admin/models/order.dart';
import 'package:final_project_admin/providers/order_provider.dart';
import 'package:final_project_admin/screens/print_bill_screen.dart';
import 'package:final_project_admin/utils/colors.dart';
import 'package:final_project_admin/utils/functions.dart';
import 'package:final_project_admin/utils/widget.dart';
import 'package:final_project_admin/widget/process_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});
  static const routeName = "/order-detail-screen";

  Future<void> connectAndPrint(Order order, List<FoodOrder> foodOrders) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    try {
      final PosPrintResult result =
          await printer.connect('192.168.1.5', port: 9100);
      if (result == PosPrintResult.success) {
        await printReceipt(printer, order, foodOrders);
        printer.disconnect();
      } else {
        print('Failed to connect: ${result.msg}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> printReceipt(
      NetworkPrinter printer, Order order, List<FoodOrder> foodOrders) async {
    printer.text(order.name, styles: PosStyles(bold: true), linesAfter: 1);
    printer.text('123 Main Street', styles: PosStyles(align: PosAlign.center));
    printer.text('Saigon, VN', styles: PosStyles(align: PosAlign.center));
    printer.text('Phone: (+84) 376681323',
        styles: PosStyles(align: PosAlign.center));
    printer.text('--------------------------------');

    // Print items
    printer.text('Items', styles: const PosStyles(underline: true));
    double totalAmount = 0;
    for (int i = 0; i < foodOrders.length; i++) {
      final foodOrder = foodOrders[i];
      totalAmount += foodOrder.quantityOrdered * foodOrder.price;
      printer.text(
          '${i + 1}. ${foodOrder.foodName} X ${foodOrder.quantityOrdered}              ${foodOrder.price}VNĐ');
    }
    printer.text('--------------------------------');

    // Print totals

    printer.text('Total:                   $totalAmount',
        styles: const PosStyles(align: PosAlign.right, bold: true));
    printer.text('--------------------------------');

    // Print footer
    printer.text('Thank you for dining with us!',
        styles: PosStyles(align: PosAlign.center));
    printer.text('--------------------------------');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final id = args!['id'];
    final orderProvider = Provider.of<OrderProvider>(context);
    final order = orderProvider.getOrderById(id);
    final foodOrders = orderProvider.getFoodOrdersById(id);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(order.name),
        actions: [
          IconButton(
            tooltip: "Print Bill",
            onPressed: () {
              // Print bluetooth
              // Navigator.of(context).pushNamed(PrintBillScreen.routeName);
              // print wifi
              connectAndPrint(order, foodOrders);
            },
            icon: const Icon(
              Icons.print,
              color: AppColors.primaryColor,
            ),
          ),
          BoxEmpty.sizeBox10,
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: Image.network(
              order.image,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, bottom: 10, top: 10, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total amount: ${order.totalAmount.toInt()} VNĐ",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      BoxEmpty.sizeBox10,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            BoxEmpty.sizeBox5,
                            Text(
                              order.isPaid ? "Paid" : "UnPaid",
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Text(order.orderDatetime.toString()),
                  BoxEmpty.sizeBox10,
                  Text(
                    "List bill",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  BoxEmpty.sizeBox5,
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        final foodOrder = foodOrders[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                (index + 1).toString(),
                              ),
                            ),
                            title: Text(
                              foodOrder.foodName,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            subtitle: Text(
                                "${foodOrder.price.toInt().toString()} VNĐ"),
                            trailing: Text(
                              "X ${order.quantityItem}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: foodOrders.length,
                    ),
                  ),
                  if (order.status != "cancelled")
                    Text(
                      "Process",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  order.status == "cancelled"
                      ? SizedBox(
                          height: 50,
                          child: Center(
                              child: Text(
                            "Đơn hàng đã hủy",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 22),
                          )),
                        )
                      : SizedBox(
                          height: 140,
                          child: ProcessTimelinePage(
                            orderId: id,
                          ),
                        ),
                  if (order.status != "cancelled" &&
                      order.status != "completed")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Action: ",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        BoxEmpty.sizeBox15,
                        IconButton.filled(
                          onPressed: () {},
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                          ),
                        ),
                        BoxEmpty.sizeBox15,
                        IconButton.filled(
                          onPressed: () {
                            orderProvider.handleChangeStatusOrder(order.id);
                          },
                          icon: Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
