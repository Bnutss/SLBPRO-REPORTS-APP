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
          filteredReports = reports.where((report) => !report['packaging_completed']).toList();
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

  Future<void> completePackaging(int reportId) async {
    try {
      final response = await http.patch(
        Uri.parse('https://slbpro.uz/reports/api/plans/$reportId/update-status/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'packaging_completed': true}),
      );

      if (response.statusCode == 200) {
        fetchReports();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Упаковка успешно завершена',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackbar('Не удалось обновить статус упаковки');
      }
    } catch (e) {
      _showErrorSnackbar('Ошибка соединения');
    }
  }

  void filterReports(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredReports = reports.where((report) => !report['packaging_completed']).toList();
      } else {
        filteredReports = reports.where((report) {
          final model = report['vendor_model'].toString().toLowerCase();
          return model.contains(query.toLowerCase()) && !report['packaging_completed'];
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
          'Отчет упаковки',
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
              Color(0xFF303F9F),
              Color(0xFF3F51B5),
              Color(0xFF5C6BC0),
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
            color: Color(0xFF303F9F),
            backgroundColor: Colors.white,
            onRefresh: fetchReports,
            child: filteredReports.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Модели для упаковки не найдены',
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
                          builder: (context) => PackagingDetailReportPage(reportId: report['id']),
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
                                  color: Color(0xFF3F51B5).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded,
                                  color: Color(0xFF3F51B5),
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
                                    color: report['packaging_completed']
                                        ? Colors.green.withOpacity(0.1)
                                        : Color(0xFF3F51B5).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: report['packaging_completed']
                                        ? Colors.green
                                        : Color(0xFF3F51B5),
                                    size: 24,
                                  ),
                                ),
                                onPressed: report['packaging_completed']
                                    ? null
                                    : () => completePackaging(report['id']),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusChip(
                                'Швейка',
                                report['sewing_completed'] ? 'Завершено' : 'В процессе',
                                report['sewing_completed'] ? Colors.green : Colors.orange,
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PackagingDetailReportPage(reportId: report['id']),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF3F51B5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                                label: const Text(
                                  'Детали',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: fetchReports,
        backgroundColor: Color(0xFF3F51B5),
        child: const Icon(Icons.refresh, color: Colors.white),
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

  Widget _buildStatusChip(String label, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}