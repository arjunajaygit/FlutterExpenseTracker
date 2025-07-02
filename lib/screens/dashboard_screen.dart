// lib/screens/dashboard_screen.dart
import 'package:expense_tracker/controllers/expense_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ExpenseController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard & Insights'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- SECTION 1: KEY METRICS ---
              _buildMetricCard(
                'This Week',
                '₹${controller.weeklyTotalSpend.value.toStringAsFixed(2)}',
                'Top Category: ${controller.topWeeklyCategory.value}',
                context
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                'This Month',
                '₹${controller.monthlyTotalSpend.value.toStringAsFixed(2)}',
                'Top Category: ${controller.topMonthlyCategory.value}',
                context
              ),
              const SizedBox(height: 16),
              _buildMetricCard(
                'This Year',
                '₹${controller.yearlyTotalSpend.value.toStringAsFixed(2)}',
                'Top Category: ${controller.topYearlyCategory.value}',
                context
              ),
              const SizedBox(height: 32),

              // --- SECTION 2: CHARTS (with new titles and subtitles) ---
              _buildBarChart(
                context,
                title: 'Weekly Spending',
                subtitle: 'Your expense graph for this week',
                categorySpends: controller.weeklyCategorySpends,
              ),
              const SizedBox(height: 24),
              _buildBarChart(
                context,
                title: 'Monthly Spending',
                subtitle: 'Your expense graph for this month',
                categorySpends: controller.monthlyCategorySpends,
              ),
              const SizedBox(height: 24),
              _buildBarChart(
                context,
                title: 'Yearly Spending',
                subtitle: 'Your expense graph for this year',
                categorySpends: controller.yearlyCategorySpends,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS FOR THE DASHBOARD ---

  Widget _buildMetricCard(String title, String value, String subtitle, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // --- THIS WIDGET IS MODIFIED TO ACCEPT A SUBTITLE ---
  Widget _buildBarChart(BuildContext context, {required String title, required String subtitle, required Map<String, double> categorySpends}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.teal.shade900.withOpacity(0.5) : Colors.teal.shade400;
    final rodColor = isDarkMode ? Colors.teal.shade200 : Colors.white;
    final backgroundRodColor = isDarkMode ? Colors.teal.shade700 : Colors.teal.shade800.withOpacity(0.5);
    final titleColor = isDarkMode ? Colors.white : Colors.white;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.white70;

    final categories = categorySpends.keys.toList();
    final values = categorySpends.values.toList();
    final double maxY = values.isEmpty ? 100 : values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display both the title and the new subtitle
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: titleColor)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: subtitleColor)),
            const SizedBox(height: 32),
            
            if (categories.isEmpty)
              const SizedBox(
                height: 200,
                child: Center(child: Text("No data for this period.", style: TextStyle(color: Colors.white70))),
              )
            else
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.grey.shade800,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final categoryName = categories[group.x.toInt()];
                          return BarTooltipItem(
                            '$categoryName\n',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            children: <TextSpan>[
                              TextSpan(
                                text: '₹${rod.toY.round()}',
                                style: const TextStyle(color: Colors.yellow, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final style = TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 14);
                            String text = categories[value.toInt()];
                            if (text.isNotEmpty) {
                              text = text[0];
                            }
                            return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                          },
                          reservedSize: 38,
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(categories.length, (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          color: rodColor,
                          width: 22,
                          borderRadius: BorderRadius.circular(6),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: backgroundRodColor,
                          )
                        )
                      ],
                    )),
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}