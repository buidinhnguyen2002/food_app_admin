import 'package:final_project_admin/models/restaurant.dart';
import 'package:final_project_admin/providers/order_provider.dart';
import 'package:final_project_admin/providers/restaurant_provider.dart';
import 'package:final_project_admin/utils/colors.dart';
import 'package:final_project_admin/utils/constants.dart';
import 'package:final_project_admin/widget/app_drawer.dart';
import 'package:final_project_admin/widget/indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const routeName = "/dashboard-screen";
  final Color leftBarColor = AppColors.primaryColor;
  final Color rightBarColor = AppColors.green;
  final Color avgColor = AppColors.red;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final double width = 30;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;
  int maxValue = 0;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    final restaurants =
        Provider.of<RestaurantProvider>(context, listen: false).restaurants;
    final List<String> restaurantIds = [];

    restaurants.forEach((res) {
      restaurantIds.add(res.id);
    });
    maxValue = Provider.of<OrderProvider>(context, listen: false)
        .getRevenueMilestone(restaurantIds)
        .toInt();
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final barGroup1 = makeGroupData(0, 5);
    List<BarChartGroupData> items = [];
    for (int i = 0; i < restaurantIds.length; i++) {
      double revenue = orderProvider.getRevenueRestaurantById(restaurantIds[i]);
      items.add(makeGroupData(i, (revenue * 20) / maxValue));
    }

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    final restaurants =
        Provider.of<RestaurantProvider>(context, listen: false).restaurants;
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: const Text("Hello Admin"),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Container(
          height: deviceSize.height - 80,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(AssetConstants.logo, width: 50),
                  const SizedBox(
                    width: 38,
                  ),
                  const Text(
                    'Revenue statistics',
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  const Text(
                    'state',
                    style: TextStyle(color: Color(0xff77839a), fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Container(
                height: 250,
                constraints:
                    const BoxConstraints(maxHeight: 250, minHeight: 200),
                child: BarChart(
                  BarChartData(
                    maxY: 20,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor:
                            const Color.fromARGB(255, 240, 249, 240),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String value = convertAmoutToSymbol(
                              Provider.of<OrderProvider>(context, listen: false)
                                  .getRevenueRestaurantById(
                                      restaurants[groupIndex].id)
                                  .toInt());
                          String tooltip = value;

                          if (touchedGroupIndex == groupIndex) {
                            String yValue = restaurants[groupIndex].name;
                            tooltip = yValue;
                          }
                          return BarTooltipItem(
                            tooltip,
                            TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event, response) {
                        if (response == null || response.spot == null) {
                          setState(() {
                            touchedGroupIndex = -1;
                            showingBarGroups = List.of(rawBarGroups);
                          });
                          return;
                        }

                        touchedGroupIndex = response.spot!.touchedBarGroupIndex;
                        setState(() {
                          if (touchedGroupIndex == 0) {
                            // Hiển thị tooltips cho nhóm 0
                          } else if (touchedGroupIndex == 1) {}
                        });

                        setState(() {
                          if (!event.isInterestedForInteractions) {
                            touchedGroupIndex = -1;
                            showingBarGroups = List.of(rawBarGroups);
                            return;
                          }
                          showingBarGroups = List.of(rawBarGroups);
                          if (touchedGroupIndex != -1) {
                            var sum = 0.0;
                            for (final rod
                                in showingBarGroups[touchedGroupIndex]
                                    .barRods) {
                              sum += rod.toY;
                            }
                            final avg = sum /
                                showingBarGroups[touchedGroupIndex]
                                    .barRods
                                    .length;

                            showingBarGroups[touchedGroupIndex] =
                                showingBarGroups[touchedGroupIndex].copyWith(
                              barRods: showingBarGroups[touchedGroupIndex]
                                  .barRods
                                  .map((rod) {
                                return rod.copyWith(
                                    toY: avg, color: widget.avgColor);
                              }).toList(),
                            );
                          }
                        });
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: bottomTitles,
                          reservedSize: 40,
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          interval: 1,
                          getTitlesWidget: leftTitles,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        left: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    barGroups: showingBarGroups,
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              const Text(
                'Transaction statistics',
                style: TextStyle(color: Colors.black, fontSize: 22),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.2,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: showingSections(),
                        ),
                      ),
                    ),
                  ),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Indicator(
                        color: AppColors.primaryColor,
                        text: 'Completed',
                        isSquare: true,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Indicator(
                        color: AppColors.red,
                        text: 'Cancelled',
                        isSquare: true,
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  String convertAmoutToSymbol(int value) {
    if (value < 1000) {
      return value.toString();
    } else if (value < 1000000) {
      double result = value / 1000.0;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}K';
    } else {
      double result = value / 1000000.0;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}M';
    }
  }

  Widget leftTitles(double value, TitleMeta meta) {
    final restaurants =
        Provider.of<RestaurantProvider>(context, listen: false).restaurants;
    final List<String> restaurantIds = [];
    restaurants.forEach((res) {
      restaurantIds.add(res.id);
    });
    final maxRevenue = Provider.of<OrderProvider>(context, listen: false)
        .getRevenueMilestone(restaurantIds);
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    // int maxValue = maxRevenue.toInt();
    String text;
    switch (value) {
      case 0:
        text = '0k';
        break;
      case 5:
        text = convertAmoutToSymbol(maxValue * 5 ~/ 20);
        break;
      case 10:
        text = convertAmoutToSymbol(maxValue * 10 ~/ 20);
        break;
      case 15:
        text = convertAmoutToSymbol(maxValue * 15 ~/ 20);
        break;
      case 20:
        text = convertAmoutToSymbol(maxValue);
        break;
      default:
        return Container();
    }

    return Row(
      children: [
        SideTitleWidget(
          axisSide: meta.axisSide,
          space: 0,
          child: Text(
            text,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // VerticalDivider(),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    final titles =
        Provider.of<RestaurantProvider>(context, listen: false).restaurants;
    final Widget text = SizedBox(
      width: 60,
      child: Text(
        titles[value.toInt()].name,
        style: const TextStyle(
          color: Color(0xff7589a2),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: widget.leftBarColor,
          width: width,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(0),
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  List<PieChartSectionData> showingSections() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final quantityCanceledOrder = orderProvider.cancelOrder.length;
    final quantityCompletedOrder = orderProvider.completeOrder.length;
    double percentCompletedOrder = (quantityCompletedOrder /
            (quantityCanceledOrder + quantityCompletedOrder)) *
        100;
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: AppColors.red,
            value: percentCompletedOrder,
            title: '$percentCompletedOrder%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: AppColors.primaryColor,
            value: 100 - percentCompletedOrder,
            title: '${100 - percentCompletedOrder}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
