// lib/screens/agendamentos_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_service.dart';

class AgendamentosScreen extends StatefulWidget {
  @override
  _AgendamentosScreenState createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  final _dbService = DatabaseService();

  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _servicos = [];
  List<Map<String, dynamic>> _agendamentos = [];

  int? _clienteIdSelecionado;
  int? _servicoIdSelecionado;
  double _valorSelecionado = 0.0;
  DateTime? _dataSelecionada;
  TimeOfDay? _horaSelecionada;
  int? _agendamentoIdParaEditar;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final clientes = await _dbService.getClientes();
    final servicos = await _dbService.getServicos();
    final agendamentos = await _dbService.getAgendamentos();

    setState(() {
      _clientes = clientes;
      _servicos = servicos;
      _agendamentos = agendamentos;
    });
  }

  Future<void> _salvarAgendamento() async {
    if (_clienteIdSelecionado == null ||
        _servicoIdSelecionado == null ||
        _dataSelecionada == null ||
        _horaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
      return;
    }

    final DateTime dataHoraFinal = DateTime(
      _dataSelecionada!.year,
      _dataSelecionada!.month,
      _dataSelecionada!.day,
      _horaSelecionada!.hour,
      _horaSelecionada!.minute,
    );

    final dadosAgendamento = {
      'clienteId': _clienteIdSelecionado,
      'servicoId': _servicoIdSelecionado,
      'dataHora': dataHoraFinal.toIso8601String(),
    };

    if (_agendamentoIdParaEditar != null) {
      await _dbService.updateAgendamento(_agendamentoIdParaEditar!, dadosAgendamento);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento alterado com sucesso!')),
      );
    } else {
      await _dbService.insertAgendamento(dadosAgendamento);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Agendamento salvo com sucesso!')),
      );
    }

    _limparFormulario();
    _carregarDados();
  }

  Future<void> _cancelarAgendamento(int id) async {
    await _dbService.updateAgendamentoStatus(id, 'Cancelado');
    _carregarDados();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Agendamento cancelado com sucesso!')),
    );
  }

  void _limparFormulario() {
    setState(() {
      _clienteIdSelecionado = null;
      _servicoIdSelecionado = null;
      _valorSelecionado = 0.0;
      _dataSelecionada = null;
      _horaSelecionada = null;
      _agendamentoIdParaEditar = null;
    });
  }

  void _preencherFormularioParaEdicao(Map<String, dynamic> agendamento) {
    final dataHora = DateTime.parse(agendamento['dataHora']);
    setState(() {
      _agendamentoIdParaEditar = agendamento['id'];
      _clienteIdSelecionado = agendamento['clienteId'];
      _servicoIdSelecionado = agendamento['servicoId'];
      _valorSelecionado = _getServicoValor(agendamento['servicoId']);
      _dataSelecionada = dataHora;
      _horaSelecionada = TimeOfDay.fromDateTime(dataHora);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Formulário preenchido para edição!')),
    );
  }

  Future<void> _selecionarData() async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _selecionarHora() async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada ?? TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _horaSelecionada = hora;
      });
    }
  }

  String _getClienteNome(int id) {
    return _clientes.firstWhere((c) => c['id'] == id, orElse: () => {'nome': 'Cliente Removido'})['nome'];
  }

  String _getServicoNome(int id) {
    return _servicos.firstWhere((s) => s['id'] == id, orElse: () => {'nome': 'Serviço Removido'})['nome'];
  }

  double _getServicoValor(int id) {
    return (_servicos.firstWhere((s) => s['id'] == id, orElse: () => {'valor': 0.0})['valor'] as double?) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agendamentos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _clienteIdSelecionado,
              hint: Text('Selecione o cliente'),
              items: _clientes
                  .map((c) => DropdownMenuItem<int>(
                value: c['id'],
                child: Text(c['nome']),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _clienteIdSelecionado = value;
                });
              },
            ),
            DropdownButtonFormField<int>(
              value: _servicoIdSelecionado,
              hint: Text('Selecione o serviço'),
              items: _servicos
                  .map((s) => DropdownMenuItem<int>(
                value: s['id'],
                child: Text('${s['nome']} - R\$ ${s['valor']}'),
              ))
                  .toList(),
              onChanged: (value) {
                final servico = _servicos.firstWhere((s) => s['id'] == value);
                setState(() {
                  _servicoIdSelecionado = value;
                  _valorSelecionado = servico['valor'];
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selecionarData,
                    child: Text(_dataSelecionada == null
                        ? 'Selecionar Data'
                        : DateFormat('dd/MM/yyyy').format(_dataSelecionada!)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selecionarHora,
                    child: Text(_horaSelecionada == null
                        ? 'Selecionar Hora'
                        : _horaSelecionada!.format(context)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _salvarAgendamento,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                  child: Text(_agendamentoIdParaEditar != null ? 'Salvar Alterações' : 'Salvar Agendamento', style: TextStyle(color: Colors.white)),
                ),
                if (_agendamentoIdParaEditar != null)
                  ElevatedButton(
                    onPressed: _limparFormulario,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    child: Text('Cancelar Edição', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
            Divider(),
            Expanded(
              child: _agendamentos.isEmpty
                  ? Center(child: Text('Nenhum agendamento encontrado'))
                  : ListView.builder(
                itemCount: _agendamentos.length,
                itemBuilder: (context, index) {
                  final agendamento = _agendamentos[index];
                  final dataHora = DateTime.parse(agendamento['dataHora']);
                  final clienteNome = _getClienteNome(agendamento['clienteId']);
                  final servicoNome = _getServicoNome(agendamento['servicoId']);
                  final status = agendamento['status'] ?? 'Pendente';

                  Color corStatus = Colors.grey;
                  if (status == 'Concluído') {
                    corStatus = Colors.green;
                  } else if (status == 'Cancelado') {
                    corStatus = Colors.red;
                  }

                  return Card(
                    color: status == 'Concluído' ? Colors.green[50] : (status == 'Cancelado' ? Colors.red[50] : null),
                    child: ListTile(
                      // --- ALTERAÇÃO AQUI ---
                      onTap: () {
                        if (status == 'Cancelado') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Não é possível editar um agendamento cancelado.')),
                          );
                        } else {
                          _preencherFormularioParaEdicao(agendamento);
                        }
                      },
                      // ----------------------
                      title: Text(
                        '$clienteNome - $servicoNome',
                        style: TextStyle(
                          decoration: status == 'Cancelado' ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('dd/MM/yyyy HH:mm').format(dataHora)} - Status: $status',
                        style: TextStyle(color: corStatus),
                      ),
                      trailing: status != 'Cancelado' ?
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => _cancelarAgendamento(agendamento['id']),
                      ) : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}