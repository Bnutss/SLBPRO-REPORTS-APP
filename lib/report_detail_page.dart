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
  final TextEditingController _quantityController = TextEditingController();
  int? remainingQuantity;

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
        remainingQuantity = reportData['remaining_quantity'];
      });
    } else {
      _showSnackBar(
        message: 'Не удалось загрузить детали отчета',
        icon: Icons.error,
        color: Colors.red,
      );
    }
  }

  Future<void> addReportPosition() async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      _showSnackBar(
        message: 'Введите корректное количество',
        icon: Icons.warning,
        color: Colors.red,
      );
      return;
    }

    if (quantity > (remainingQuantity ?? 0)) {
      _showSnackBar(
        message: 'Превышено допустимое количество. Осталось кроя: $remainingQuantity',
        icon: Icons.error_outline,
        color: Colors.red,
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/reports/api/report/${widget.reportId}/add-position/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'quantity': quantity}),
    );

    if (response.statusCode == 201) {
      _quantityController.clear();
      _showSnackBar(
        message: 'Позиция успешно добавлена, отчет отправлен в Telegram',
        icon: Icons.check_circle,
        color: Colors.green,
      );
      fetchReportDetail();
    } else {
      _showSnackBar(
        message: json.decode(response.body)['error'] ?? 'Ошибка при добавлении позиции',
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
            : Padding(
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
                      _buildReportInfoRow(Icons.inventory, 'Остаток кроя', (remainingQuantity ?? 0).toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Количество для добавления',
                  labelStyle: const TextStyle(color: Colors.indigo),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.add, color: Colors.indigo),
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
                enabled: remainingQuantity != null && remainingQuantity! > 0,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: remainingQuantity != null && remainingQuantity! > 0
                      ? addReportPosition
                      : null,
                  child: const Icon(Icons.add, color: Colors.white),
                  backgroundColor: Colors.indigo,
                ),
              ),
            ],
          ),
        ),
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
}
