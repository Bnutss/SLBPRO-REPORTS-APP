import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'packaging_detail_report.dart';

class PackagingReportPage extends StatefulWidget {
  const PackagingReportPage({Key? key}) : super(key: key);

  @override
  _PackagingReportPageState createState() => _PackagingReportPageState();
}

class _PackagingReportPageState extends State<PackagingReportPage> {
  List<dynamic> reports = [];
  List<dynamic> filteredReports = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/reports/api/plans/'));

    if (response.statusCode == 200) {
      setState(() {
        reports = json.decode(utf8.decode(response.bodyBytes));
        filteredReports = reports;
      });
    } else {
      throw Exception('Не удалось загрузить отчеты');
    }
  }

  void filterReports(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReports = reports;
      } else {
        filteredReports = reports.where((report) {
          final model = report['vendor_model'].toString().toLowerCase();
          return model.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ежечасный отчет упаковки',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              onChanged: filterReports,
              decoration: InputDecoration(
                hintText: 'Поиск по моделям...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.white24],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fetchReports,
          child: filteredReports.isEmpty
              ? const Center(child: Text('Модели не найдены'))
              : ListView.builder(
            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              final report = filteredReports[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    Icons.article,
                    color: Colors.indigo,
                    size: 40,
                  ),
                  title: Text(
                    report['name'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.style, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${report['vendor_model']}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.color_lens, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Цвет: ${report['color']}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.production_quantity_limits, color: Colors.grey, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Количество кроя: ${report['cutting_quantity']}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportDetailPage(reportId: report['id']),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
