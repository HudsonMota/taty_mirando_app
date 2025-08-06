// lib/screens/conclusao_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_service.dart';

class ConclusaoScreen extends StatefulWidget {
  @override
  _ConclusaoScreenState createState() => _ConclusaoScreenState();
}

class _ConclusaoScreenState extends State<ConclusaoScreen> {
  final _dbService = DatabaseService();
  List<Map<String, dynamic>> _agendamentos = [];
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final agendamentos = await _dbService.getAgendamentos();
    final clientes = await _dbService.getClientes();
    final servicos = await _dbService.getServicos();

    setState(() {
      _agendamentos = agendamentos;
      _clientes = clientes;
      _servicos = servicos;
    });
  }

  Future<void> _marcarConcluido(int id) async {
    await _dbService.updateAgendamentoStatus(id, 'Concluído');
    _carregarDados();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento marcado como concluído!')),
    );
  }

  void _mostrarRecibo(Map<String, dynamic> agendamento) {
    final dataHora = DateTime.parse(agendamento['dataHora']);
    final cliente = _clientes.firstWhere((c) => c['id'] == agendamento['clienteId'], orElse: () => {'nome': 'Cliente Removido'});
    final servico = _servicos.firstWhere((s) => s['id'] == agendamento['servicoId'], orElse: () => {'nome': 'Serviço Removido', 'valor': 0.0});

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recibo de Pagamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${cliente['nome']}'),
            Text('Serviço: ${servico['nome']}'),
            Text('Valor: R\$ ${servico['valor'].toStringAsFixed(2)}'),
            Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(dataHora)}'),
            Text('Status: ${agendamento['status'] ?? 'Pendente'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conclusão de Agendamentos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _agendamentos.isEmpty
            ? Center(child: Text('Nenhum agendamento encontrado'))
            : ListView.builder(
          itemCount: _agendamentos.length,
          itemBuilder: (context, index) {
            final agendamento = _agendamentos[index];
            final dataHora = DateTime.parse(agendamento['dataHora']);

            if (_clientes.isEmpty || _servicos.isEmpty) {
              return CircularProgressIndicator();
            }

            final cliente = _clientes.firstWhere((c) => c['id'] == agendamento['clienteId'], orElse: () => {'nome': 'Cliente Removido'});
            final servico = _servicos.firstWhere((s) => s['id'] == agendamento['servicoId'], orElse: () => {'nome': 'Serviço Removido', 'valor': 0.0});

            final bool isConcluido = agendamento['status'] == 'Concluído';

            return Card(
              color: isConcluido ? Colors.green[50] : null,
              child: ListTile(
                title: Text('${cliente['nome']} - ${servico['nome']}'),
                subtitle: Text(
                  '${DateFormat('dd/MM/yyyy HH:mm').format(dataHora)} - R\$ ${servico['valor'].toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.receipt_long, color: Colors.blue),
                      onPressed: () => _mostrarRecibo(agendamento),
                    ),
                    // --- ALTERAÇÃO AQUI ---
                    if (agendamento['status'] != 'Concluído' && agendamento['status'] != 'Cancelado')
                      IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _marcarConcluido(agendamento['id']),
                      ),
                    // ----------------------
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}