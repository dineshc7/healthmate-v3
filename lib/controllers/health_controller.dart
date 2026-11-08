import '../database/database_helper.dart';
import '../models/health_record.dart';

class HealthController {
  final DatabaseHelper _db = DatabaseHelper.instance;
 
  Future<int> addRecord(HealthRecord record) async {
    return _db.insertRecord(record.toMap());
  }
 
  Future<List<HealthRecord>> getAllRecords() async {
    final rows = await _db.getAllRecords();
    return rows.map((row) => HealthRecord.fromMap(row)).toList();
  }
 
  Future<int> updateRecord(HealthRecord record) async {
    if (record.id == null) {
      throw ArgumentError('A record ID is required for updating.');
    }
    return _db.updateRecord(record.id!, record.toMap());
  }
 
  Future<int> deleteRecord(int id) async {
    return _db.deleteRecord(id);
  }
 
  Future<List<HealthRecord>> getRecordsByDate(String date) async {
    final rows = await _db.getRecordsByDate(date);
    return rows.map((row) => HealthRecord.fromMap(row)).toList();
  }
 
  Future<List<HealthRecord>> getTodayRecords() async {
    final today = DateTime.now();
    final date = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    return getRecordsByDate(date);
  }
}

