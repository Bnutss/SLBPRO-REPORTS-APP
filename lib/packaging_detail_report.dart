import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class PackagingDetailReportPage extends StatefulWidget {
  final int reportId;

  const PackagingDetailReportPage({Key? key, required this.reportId}) : super(key: key);

  @override
  _ReportDetailPageState createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<PackagingDetailReportPage> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? report;
  final TextEditingController _ironingController = TextEditingController();
  final TextEditingController _cleaningController = TextEditingController();
  final TextEditingController _controlController = TextEditingController();
  final TextEditingController _accessoriesController = TextEditingController();
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500)
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    _animationController.forward();
    fetchReportDetail();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _ironingController.dispose();
    _cleaningController.dispose();
    _controlController.dispose();
    _accessoriesController.dispose();
    super.dispose();
  }

  Future<void> fetchReportDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://slbpro.uz/reports/api/plans/${widget.reportId}/'),
      );

      if (response.statusCode == 200) {
        final reportData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          report = reportData;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showSnackBar(
          message: 'Не удалось загрузить детали отчета',
          icon: Icons.error_outline_rounded,
          color: const Color(0xFFE53935),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar(
        message: 'Ошибка соединения',
        icon: Icons.wifi_off_rounded,
        color: const Color(0xFFE53935),
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
        icon: Icons.warning_rounded,
        color: const Color(0xFFFFA726),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse('https://slbpro.uz/reports/api/packaging-reports/');
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'report': widget.reportId,
        'ironing_quantity': ironingQuantity,
        'cleaning_quantity': cleaningQuantity,
        'control_quantity': controlQuantity,
        'accessories_quantity': accessoriesQuantity,
      });

      final response = await http.post(url, headers: headers, body: body);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 201) {
        _showSnackBar(
          message: 'Отчет об упаковке успешно создан',
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF43A047),
        );
        _ironingController.clear();
        _cleaningController.clear();
        _controlController.clear();
        _accessoriesController.clear();
      } else {
        _showSnackBar(
          message: 'Ошибка при создании отчета об упаковке',
          icon: Icons.error_rounded,
          color: const Color(0xFFE53935),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar(
        message: 'Ошибка соединения',
        icon: Icons.wifi_off_rounded,
        color: const Color(0xFFE53935),
      );
    }
  }

  void _showSnackBar({required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'SLBPRO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            ),
            onPressed: fetchReportDetail,
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF303F9F),
                  Color(0xFF3949AB),
                  Color(0xFF3F51B5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
                : report == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 70,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Не удалось загрузить данные',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: fetchReportDetail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3949AB),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Повторить', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
                : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        report!['name'] ?? 'Детали упаковки',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Отчет по упаковке продукции',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      _buildInfoCard(),
                      const SizedBox(height: 24),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3F51B5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "Информация о продукте",
                  style: TextStyle(
                    color: Color(0xFF3F51B5),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildReportInfoRow(
              Icons.style_rounded,
              'Модель',
              report!['vendor_model'],
            ),
            _buildReportInfoRow(
              Icons.people_alt_rounded,
              'Группа',
              report!['vendor_model_group'],
            ),
            _buildReportInfoRow(
              Icons.palette_rounded,
              'Цвет',
              report!['color'],
            ),
            _buildReportInfoRow(
              Icons.content_cut_rounded,
              'Количество кроя',
              '${report!['cutting_quantity']}',
              hasDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Color(0xFF3F51B5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  "Добавить отчет упаковки",
                  style: TextStyle(
                    color: Color(0xFF3F51B5),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _ironingController,
              label: 'Количество глажки',
              icon: Icons.iron_rounded,
              hint: 'Введите количество глажки',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cleaningController,
              label: 'Количество чистки',
              icon: Icons.cleaning_services_rounded,
              hint: 'Введите количество чистки',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _controlController,
              label: 'Количество контроля',
              icon: Icons.fact_check_rounded,
              hint: 'Введите количество контроля',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _accessoriesController,
              label: 'Количество аксессуаров',
              icon: Icons.category_rounded,
              hint: 'Введите количество аксессуаров',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: addPackagingReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF3F51B5).withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Отправить отчет',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF3F51B5),
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportInfoRow(
      IconData icon,
      String label,
      String value, {
        bool hasDivider = true,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF3F51B5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasDivider)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
        ],
      ),
    );
  }
}