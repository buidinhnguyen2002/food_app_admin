import 'package:final_project_admin/providers/order_provider.dart';
import 'package:final_project_admin/utils/widget.dart';
import 'package:final_project_admin/widget/app_drawer.dart';
import 'package:final_project_admin/widget/order_manager_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderManagerScreen extends StatelessWidget {
  const OrderManagerScreen({super.key});
  static const routeName = "/order-screen";
  Widget paginationButton(BuildContext context, int index, int selectedPage) {
    return Container(
      width: 45.0,
      height: 45.0,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == selectedPage
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
      ),
      child: InkWell(
        onTap: () {
          Provider.of<OrderProvider>(context, listen: false)
              .changePageOrder(index);
        },
        borderRadius: BorderRadius.circular(30),
        child: Center(
          child: Text(
            (index + 1).toString(),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final order = Provider.of<OrderProvider>(context);
    final quantityPage = order.quantityPage;
    final selectedPage = order.selectedPage;
    final orderInPage = order.getPageOrder(selectedPage);
    final indexFrom = selectedPage - 2 > 0 ? selectedPage - 2 : 0;
    final indexTo = selectedPage + 2 > quantityPage - 1
        ? quantityPage - 1
        : selectedPage + 2;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "Order manager",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final order = orderInPage[index];
                  return OrderManagerItem(
                    id: order.id,
                    title: order.name,
                    orderTime: order.orderDatetime.toString(),
                    totalAmount: order.totalAmount,
                    status: order.status,
                  );
                },
                itemCount: orderInPage.length,
              ),
            ),
            BoxEmpty.sizeBox10,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {
                    Provider.of<OrderProvider>(context, listen: false)
                        .decreaseIndexPage();
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_rounded,
                  ),
                ),
                BoxEmpty.sizeBox5,
                for (int i = indexFrom; i < indexTo + 1; i++)
                  paginationButton(context, i, selectedPage),
                IconButton.filled(
                  onPressed: () {
                    Provider.of<OrderProvider>(context, listen: false)
                        .incrementPage();
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
