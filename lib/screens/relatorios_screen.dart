// lib/screens/relatorios_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_service.dart';

class RelatoriosScreen extends StatefulWidget {
  @override
  _RelatoriosScreenState createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final _dbService = DatabaseService();
  final _currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  double _totalDiario = 0.0;
  double _totalSemanal = 0.0;
  double _totalMensal = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calcularRelatorios();
  }

  Future<void> _calcularRelatorios() async {
    setState(() {
      _isLoading = true;
    });

    final hoje = DateTime.now();

    final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
    final fimDia = inicioDia.add(Duration(days: 1));

    final inicioSemana = hoje.subtract(Duration(days: hoje.weekday - 1));
    final fimSemana = inicioSemana.add(Duration(days: 7));

    final inicioMes = DateTime(hoje.year, hoje.month, 1);
    final fimMes = DateTime(hoje.year, hoje.month + 1, 1);

    _totalDiario = await _dbService.getTotalFaturamento(inicioDia, fimDia);
    _totalSemanal = await _dbService.getTotalFaturamento(inicioSemana, fimSemana);
    _totalMensal = await _dbService.getTotalFaturamento(inicioMes, fimMes);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Relatórios de Faturamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text('Faturamento Diário'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.now())),
                trailing: Text(_currencyFormatter.format(_totalDiario)),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Faturamento Semanal'),
                subtitle: Text('Semana ${DateFormat('w').format(DateTime.now())}'),
                trailing: Text(_currencyFormatter.format(_totalSemanal)),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Faturamento Mensal'),
                subtitle: Text(DateFormat('MMMM yyyy', 'pt_BR').format(DateTime.now())),
                trailing: Text(_currencyFormatter.format(_totalMensal)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcularRelatorios,
              child: Text('Atualizar Relatórios'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            ),
          ],
        ),
      ),
    );
  }
}