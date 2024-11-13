import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'hourly_report.dart';
import 'daily_report.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Меню',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 4.0,
        shadowColor: Colors.grey.withOpacity(0.5),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.grey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HourlyReportPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.indigo,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  elevation: 5,
                ),
                icon: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                ),
                label: const Text(
                  'Ежечасный отчет',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DailyReportPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  backgroundColor: Colors.indigoAccent,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  elevation: 5,
                ),
                icon: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                ),
                label: const Text(
                  'Ежедневный отчет',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
