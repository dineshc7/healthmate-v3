import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/health_controller.dart';
import '../models/health_record.dart';
import '../widgets/metric_card.dart';
import 'record_form_screen.dart';
import 'record_list_screen.dart';
 
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
 
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
 
class _DashboardScreenState extends State<DashboardScreen> {
  final _controller = HealthController();
  List<HealthRecord> _todayRecords = [];
  bool _isLoading = true;
 
  int get _steps =>
      _todayRecords.fold(0, (sum, item) => sum + item.steps);
  int get _calories =>
      _todayRecords.fold(0, (sum, item) => sum + item.calories);
  int get _water =>
      _todayRecords.fold(0, (sum, item) => sum + item.waterMl);
 
  @override
  void initState() {
    super.initState();
    _loadToday();
  }
 
  Future<void> _loadToday() async {
    final records = await _controller.getTodayRecords();
    if (!mounted) return;
    setState(() {
      _todayRecords = records;
      _isLoading = false;
    });
  }
 
  Future<void> _openAddForm() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RecordFormScreen()),
    );
    if (changed == true) await _loadToday();
  }
 
  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecordListScreen()),
    );
    await _loadToday();
  }
 
  @override
  Widget build(BuildContext context) {
    final todayLabel = DateFormat('dd MMMM yyyy').format(DateTime.now());
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate'),
        actions: [
          IconButton(
            onPressed: _openHistory,
            icon: const Icon(Icons.history),
            tooltip: 'History',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadToday,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Today – $todayLabel',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  MetricCard(
                    title: 'Steps walked',
                    value: _steps.toString(),
                    unit: 'steps',
                    icon: Icons.directions_walk,
                  ),
                  MetricCard(
                    title: 'Calories burned',
                    value: _calories.toString(),
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                  ),
                  MetricCard(
                    title: 'Water intake',
                    value: _water.toString(),
                    unit: 'ml',
                    icon: Icons.water_drop,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _openAddForm,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Health Record'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openHistory,
                    icon: const Icon(Icons.history),
                    label: const Text('View Previous Records'),
                  ),
                  if (_todayRecords.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Text(
                        'No entries for today yet. Add your first health record.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}