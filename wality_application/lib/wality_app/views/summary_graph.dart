import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wality_application/wality_app/utils/fl_chart_wality.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';

class SummaryGraphPage extends StatefulWidget {
  const SummaryGraphPage({super.key});

  @override
  State<SummaryGraphPage> createState() => _SummaryGraphPageState();
}

class _SummaryGraphPageState extends State<SummaryGraphPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WaterSaveViewModel>(builder: (context, uservm, child) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.maxFinite,
                height: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF0083AB),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          size: 32,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Summary Graph',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoCondensed',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150,
              child: Container(
                padding: const EdgeInsets.only(left: 15, top: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 1, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FlChartWality(),
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Last 10 days',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'RobotoCondensed',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text(
                            'Status :',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'RobotoCondensed',
                            ),
                          ),
                          SizedBox(width: 4),
                          Text('GOOD',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontFamily: 'RobotoCondensed',
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Text(
                            'latest filter install :',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'RobotoCondensed',
                            ),
                          ),
                          SizedBox(width: 4),
                          Text('1/4/2024',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'RobotoCondensed',
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
