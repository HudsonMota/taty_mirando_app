// lib/database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'salao.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        telefone TEXT,
        endereco TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE servicos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        valor REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE agendamentos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clienteId INTEGER,
        servicoId INTEGER,
        dataHora TEXT,
        status TEXT DEFAULT 'Pendente'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE agendamentos ADD COLUMN status TEXT DEFAULT 'Pendente'");
    }
  }

  // Funções de CRUD para Clientes
  Future<int> insertCliente(Map<String, dynamic> cliente) async =>
      await (await database).insert('clientes', cliente);

  Future<List<Map<String, dynamic>>> getClientes() async =>
      await (await database).query('clientes');

  Future<int> deleteCliente(int id) async =>
      await (await database).delete('clientes', where: 'id = ?', whereArgs: [id]);

  // Funções de CRUD para Serviços
  Future<int> insertServico(Map<String, dynamic> servico) async =>
      await (await database).insert('servicos', servico);

  Future<List<Map<String, dynamic>>> getServicos() async =>
      await (await database).query('servicos');

  Future<int> deleteServico(int id) async =>
      await (await database).delete('servicos', where: 'id = ?', whereArgs: [id]);

  // Funções de CRUD para Agendamentos
  Future<int> insertAgendamento(Map<String, dynamic> agendamento) async =>
      await (await database).insert('agendamentos', agendamento);

  Future<List<Map<String, dynamic>>> getAgendamentos() async =>
      await (await database).query('agendamentos');

  Future<int> updateAgendamentoStatus(int id, String status) async =>
      await (await database).update('agendamentos', {'status': status}, where: 'id = ?', whereArgs: [id]);

  Future<int> updateAgendamento(int id, Map<String, dynamic> agendamento) async =>
      await (await database).update('agendamentos', agendamento, where: 'id = ?', whereArgs: [id]);

  // Funções de Relatórios
  Future<double> getTotalFaturamento(DateTime inicio, DateTime fim) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(valor) as total FROM agendamentos a
      JOIN servicos s ON a.servicoId = s.id
      WHERE a.status = 'Concluído' 
      AND datetime(a.dataHora) >= ? AND datetime(a.dataHora) < ?
    ''', [inicio.toIso8601String(), fim.toIso8601String()]);

    final total = result.first['total'] as double?;
    return total ?? 0.0;
  }
}