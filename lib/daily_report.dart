import 'package:flutter/material.dart';

class DailyReportPage extends StatelessWidget {
  const DailyReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ежедневный отчет'),
      ),
      body: Center(
        child: const Text(
          'В разработке...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
