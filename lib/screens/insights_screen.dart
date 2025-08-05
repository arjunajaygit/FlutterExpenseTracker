// lib/screens/insights_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:expense_tracker/main.dart'; // Import for AppColors
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController controller = Get.find();
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard & Insights'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMetricCard(
                icon: IconlyBold.calendar,
                color: Colors.orange,
                label: 'This Week',
                value: currencyFormatter.format(controller.weeklyTotalSpend.value),
                context: context,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                icon: IconlyBold.discovery,
                color: Colors.blue,
                label: 'This Month',
                value: currencyFormatter.format(controller.monthlyTotalSpend.value),
                context: context,
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                icon: IconlyBold.graph,
                color: Colors.pink,
                label: 'This Year',
                value: currencyFormatter.format(controller.yearlyTotalSpend.value),
                context: context,
              ),
              const SizedBox(height: 32),
              _buildBarChart(
                context,
                title: 'Weekly Spending',
                categorySpends: controller.weeklyCategorySpends,
              ),
              const SizedBox(height: 24),
              _buildBarChart(
                context,
                title: 'Monthly Spending',
                categorySpends: controller.monthlyCategorySpends,
              ),
              const SizedBox(height: 24),
              _buildBarChart(
                context,
                title: 'Yearly Spending',
                categorySpends: controller.yearlyCategorySpends,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary, fontSize: 14),
                ),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- THIS WIDGET IS NOW FULLY THEME-AWARE ---
  Widget _buildBarChart(BuildContext context,
      {required String title, required Map<String, double> categorySpends}) {
        
    // The only hardcoded color is the track background, as requested.
    final backgroundRodColor = Colors.grey.shade300; 

    final categories = categorySpends.keys.toList();
    final values = categorySpends.values.toList();
    final double maxY = values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      // The card color will now adapt to the theme (white in light, dark in dark)
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                // Text color adapts to the theme
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Your expense graph for this period',
                // Text color adapts to the theme
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary)),
            const SizedBox(height: 32),
            if (categories.isEmpty)
              SizedBox(
                height: 200,
                child: Center(
                    child: Text("No data for this period.",
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
              )
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Theme.of(context).scaffoldBackgroundColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final categoryName = categories[group.x.toInt()];
                          return BarTooltipItem(
                            '$categoryName\n',
                             TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                text: '₹${rod.toY.round()}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final style = TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12);
                            String text = categories[value.toInt()];
                            if (text.isNotEmpty) {
                              text = text[0];
                            }
                            return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(text, style: style));
                          },
                          reservedSize: 38,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: List.generate(
                      categories.length,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: values[i],
                            gradient: AppColors.primaryGradient,
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY,
                              color: backgroundRodColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}