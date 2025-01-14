import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportDetailPage extends StatefulWidget {
  final int reportId;

  const ReportDetailPage({Key? key, required this.reportId}) : super(key: key);

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  Map<String, dynamic>? report;
  final TextEditingController _ironingController = TextEditingController();
  final TextEditingController _cleaningController = TextEditingController();
  final TextEditingController _controlController = TextEditingController();
  final TextEditingController _accessoriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReportDetail();
  }

  Future<void> fetchReportDetail() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/reports/api/plans/${widget.reportId}/'),
    );

    if (response.statusCode == 200) {
      final reportData = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        report = reportData;
      });
    } else {
      _showSnackBar(
        message: 'Не удалось загрузить детали отчета',
        icon: Icons.error,
        color: Colors.red,
      );
    }
  }

  Future<void> addPackagingReport() async {
    final ironingQuantity = int.tryParse(_ironingController.text);
    final cleaningQuantity = int.tryParse(_cleaningController.text);
    final controlQuantity = int.tryParse(_controlController.text);
    final accessoriesQuantity = int.tryParse(_accessoriesController.text);

    if (ironingQuantity == null || cleaningQuantity == null || controlQuantity == null || accessoriesQuantity == null) {
      _showSnackBar(
        message: 'Все поля должны быть заполнены корректными числами',
        icon: Icons.warning,
        color: Colors.red,
      );
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/reports/api/packaging-reports/');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'report': widget.reportId,
      'ironing_quantity': ironingQuantity,
      'cleaning_quantity': cleaningQuantity,
      'control_quantity': controlQuantity,
      'accessories_quantity': accessoriesQuantity,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      _showSnackBar(
        message: 'Отчет об упаковке успешно создан',
        icon: Icons.check_circle,
        color: Colors.green,
      );
      _ironingController.clear();
      _cleaningController.clear();
      _controlController.clear();
      _accessoriesController.clear();
    } else {
      _showSnackBar(
        message: 'Ошибка при создании отчета об упаковке',
        icon: Icons.error,
        color: Colors.red,
      );
    }
  }

  void _showSnackBar({required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали отчета', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.grey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
        child: report == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReportInfoRow(Icons.model_training, 'Модель', report!['vendor_model']),
                      _buildReportInfoRow(Icons.color_lens, 'Цвет', report!['color']),
                      _buildReportInfoRow(Icons.cut, 'Количество кроя', report!['cutting_quantity'].toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Добавить отчет об упаковке',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 10),
              _buildPackagingTextField(_ironingController, 'Количество глажки', Icons.iron),
              const SizedBox(height: 10),
              _buildPackagingTextField(_cleaningController, 'Количество чистки', Icons.cleaning_services),
              const SizedBox(height: 10),
              _buildPackagingTextField(_controlController, 'Количество контроля', Icons.checklist),
              const SizedBox(height: 10),
              _buildPackagingTextField(_accessoriesController, 'Количество аксессуаров', Icons.style),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPackagingReport,
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildReportInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 24),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.indigo),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }
}