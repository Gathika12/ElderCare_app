import 'package:elder_care/apiservice.dart';
import 'package:elder_care/screens/customer/add_metrics.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewMetricsScreen extends StatefulWidget {
  final String userId;

  ViewMetricsScreen({Key? key, required this.userId}) : super(key: key);
  @override
  _ViewMetricsScreenState createState() => _ViewMetricsScreenState();
}

class _ViewMetricsScreenState extends State<ViewMetricsScreen> {
  final RentApi apiService = RentApi();
  List<dynamic> _metrics = [];
  double totalWeight = 0;
  double totalSugar = 0;
  double totalSystolicBP = 0;
  double totalDiastolicBP = 0;
  String healthStatus = "Unknown";

  Future<void> fetchMetrics() async {
    final response = await http.get(
      Uri.parse(
          'http://gathikacolambage.site/eldercare/get_metrics.php?user_id=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _metrics = json.decode(response.body);
        _calculateTotals();
        _determineHealthStatus();
      });
    } else {
      print('Failed to load metrics.');
    }
  }

  void _calculateTotals() {
    totalWeight = 0;
    totalSugar = 0;
    totalSystolicBP = 0;
    totalDiastolicBP = 0;

    for (var metric in _metrics) {
      totalWeight += double.tryParse(metric['weight'] ?? '0') ?? 0;
      totalSugar += double.tryParse(metric['sugar_level'] ?? '0') ?? 0;

      String bp = metric['blood_pressure'] ?? '0/0';
      List<String> bpValues = bp.split('/');
      if (bpValues.length == 2) {
        totalSystolicBP += double.tryParse(bpValues[0]) ?? 0;
        totalDiastolicBP += double.tryParse(bpValues[1]) ?? 0;
      }
    }
  }

  void _determineHealthStatus() {
    // Average metrics for status calculation
    double avgWeight = totalWeight / _metrics.length;
    double avgSugar = totalSugar / _metrics.length;
    double avgSystolicBP = totalSystolicBP / _metrics.length;
    double avgDiastolicBP = totalDiastolicBP / _metrics.length;

    // Evaluate health status
    if (avgWeight >= 50 &&
        avgWeight <= 80 &&
        avgSugar >= 70 &&
        avgSugar <= 140 &&
        avgSystolicBP >= 90 &&
        avgSystolicBP <= 120 &&
        avgDiastolicBP >= 60 &&
        avgDiastolicBP <= 80) {
      healthStatus = "Good";
    } else if ((avgWeight < 50 || avgWeight > 80) ||
        (avgSugar < 70 || avgSugar > 140) ||
        (avgSystolicBP < 90 || avgSystolicBP > 120) ||
        (avgDiastolicBP < 60 || avgDiastolicBP > 80)) {
      healthStatus = "Average";
    } else {
      healthStatus = "Critical";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMetrics();
  }

  void _navigateToAddMetricsScreen() async {
    // Navigator.push waits for the screen to pop and return a value
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMetricsScreen(userId: widget.userId),
      ),
    );

    if (result != null) {
      // Ensure result is properly handled
      print('New Metrics Added: $result');

      // If you're updating a list or state, do so here
      setState(() {
        // Assuming you have a list of metrics
        _metrics.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Metrics (Pie Chart)'),
        actions: [
          TextButton(
            onPressed:
                _navigateToAddMetricsScreen, // Pass the function reference
            child: Text(
              'Add Details',
              style: TextStyle(
                color: Colors.teal, // Text color
                fontSize: 16, // Text size
              ),
            ),
          ),
        ],
      ),
      body: _metrics.isEmpty
          ? Center(
              child: Text(
                'No data available to display.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Overview of Health Metrics',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildHealthStatus(),
                    SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieChartSections(),
                          centerSpaceRadius: 70,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildDetailsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHealthStatus() {
    Color statusColor;
    switch (healthStatus) {
      case "Good":
        statusColor = Colors.green;
        break;
      case "Average":
        statusColor = Colors.orange;
        break;
      case "Critical":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.health_and_safety, color: statusColor),
          SizedBox(width: 10),
          Text(
            "Health Status: $healthStatus",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final total = totalWeight + totalSugar + totalSystolicBP + totalDiastolicBP;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey,
          value: 1,
          title: 'No Data',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: Colors.blue,
        value: totalWeight / total * 100,
        title: '${(totalWeight / total * 100).toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: totalSugar / total * 100,
        title: '${(totalSugar / total * 100).toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.green,
        value: totalSystolicBP / total * 100,
        title: '${(totalSystolicBP / total * 100).toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: totalDiastolicBP / total * 100,
        title: '${(totalDiastolicBP / total * 100).toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLegend(),
        SizedBox(height: 10),
        Text(
          'Total Weight: ${totalWeight.toStringAsFixed(1)} kg',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Total Sugar Level: ${totalSugar.toStringAsFixed(1)} mg/dL',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Total Systolic BP: ${totalSystolicBP.toStringAsFixed(1)} mmHg',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Total Diastolic BP: ${totalDiastolicBP.toStringAsFixed(1)} mmHg',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 10,
      children: [
        _buildLegendItem('Weight', Colors.blue),
        _buildLegendItem('Sugar Level', Colors.red),
        _buildLegendItem('Systolic BP', Colors.green),
        _buildLegendItem('Diastolic BP', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}
