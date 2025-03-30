import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'report_detail_page.dart';

class HourlyReportPage extends StatefulWidget {
  const HourlyReportPage({Key? key}) : super(key: key);

  @override
  _HourlyReportPageState createState() => _HourlyReportPageState();
}

class _HourlyReportPageState extends State<HourlyReportPage> {
  List<dynamic> reports = [];
  List<dynamic> filteredReports = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://slbpro.uz/reports/api/plans/'));

      if (response.statusCode == 200) {
        setState(() {
          reports = json.decode(utf8.decode(response.bodyBytes));
          filteredReports = reports.where((report) => !report['sewing_completed']).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackbar('Не удалось загрузить отчеты');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar('Ошибка соединения');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> completeSewing(int reportId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://slbpro.uz/reports/api/plans/$reportId/update-status/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sewing_completed': true}),
      );

      if (response.statusCode == 200) {
        fetchReports();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Успешно завершено',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackbar('Не удалось обновить статус швейки');
      }
    } catch (e) {
      _showErrorSnackbar('Ошибка соединения');
    }
  }

  void filterReports(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReports = reports.where((report) => !report['sewing_completed']).toList();
      } else {
        filteredReports = reports.where((report) {
          final model = report['vendor_model'].toString().toLowerCase();
          return model.contains(query.toLowerCase()) && !report['sewing_completed'];
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Ежечасный отчет',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterReports,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Поиск по моделям...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A237E),
              Color(0xFF303F9F),
              Color(0xFF3949AB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : RefreshIndicator(
            color: Color(0xFF1A237E),
            backgroundColor: Colors.white,
            onRefresh: fetchReports,
            child: filteredReports.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 70,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Модели не найдены',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  shadowColor: Colors.black26,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailPage(reportId: report['id']),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3949AB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.article_rounded,
                                  color: Color(0xFF3949AB),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  report['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF303F9F),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: report['sewing_completed']
                                        ? Colors.green.withOpacity(0.1)
                                        : Color(0xFF303F9F).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: report['sewing_completed']
                                        ? Colors.green
                                        : Color(0xFF303F9F),
                                    size: 24,
                                  ),
                                ),
                                onPressed: report['sewing_completed']
                                    ? null
                                    : () => completeSewing(report['id']),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            Icons.style_rounded,
                            'Модель:',
                            '${report['vendor_model']}',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            Icons.color_lens_rounded,
                            'Цвет:',
                            '${report['color']}',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            Icons.content_cut_rounded,
                            'Количество кроя:',
                            '${report['cutting_quantity']}',
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportDetailPage(reportId: report['id']),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF303F9F),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Подробнее',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}