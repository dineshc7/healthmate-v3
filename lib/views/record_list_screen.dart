import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/health_controller.dart';
import '../models/health_record.dart';
import 'record_form_screen.dart';
 
class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});
 
  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}
 
class _RecordListScreenState extends State<RecordListScreen> {
  final _controller = HealthController();
  List<HealthRecord> _records = [];
  DateTime? _filterDate;
  bool _isLoading = true;
 
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }
 
  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = _filterDate == null
        ? await _controller.getAllRecords()
        : await _controller.getRecordsByDate(
            DateFormat('yyyy-MM-dd').format(_filterDate!),
          );
 
    if (!mounted) return;
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }
 
  Future<void> _chooseFilterDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _filterDate = picked);
      await _loadRecords();
    }
  }
 
  Future<void> _editRecord(HealthRecord record) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecordFormScreen(record: record),
      ),
    );
    if (changed == true) await _loadRecords();
  }
 
  Future<void> _deleteRecord(HealthRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
 
    if (confirm == true && record.id != null) {
      await _controller.deleteRecord(record.id!);
      await _loadRecords();
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(_filterDate == null
                      ? 'Showing all records'
                      : 'Date: ${DateFormat('dd MMM yyyy').format(_filterDate!)}'),
                ),
                TextButton(
                  onPressed: _chooseFilterDate,
                  child: const Text('Filter date'),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _filterDate = null);
                    _loadRecords();
                  },
                  tooltip: 'Clear filter',
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _records.isEmpty
                    ? const Center(child: Text('No health records found.'))
                    : ListView.builder(
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5,
                            ),
                            child: ListTile(
                              title: Text(DateFormat('dd MMM yyyy')
                                  .format(DateTime.parse(record.date))),
                              subtitle: Text(
                                'Steps: ${record.steps} | '
                                'Calories: ${record.calories} kcal | '
                                'Water: ${record.waterMl} ml',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') _editRecord(record);
                                  if (value == 'delete') _deleteRecord(record);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                     value: 'edit', child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete', child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}