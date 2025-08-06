// lib/screens/servicos_screen.dart

import 'package:flutter/material.dart';
import '../database_service.dart';
import 'package:flutter/services.dart';

class ServicosScreen extends StatefulWidget {
  @override
  _ServicosScreenState createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  final _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();

  List<Map<String, dynamic>> _servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    final servicos = await _dbService.getServicos();
    setState(() {
      _servicos = servicos;
    });
  }

  Future<void> _salvarServico() async {
    if (_formKey.currentState!.validate()) {
      await _dbService.insertServico({
        'nome': _nomeController.text,
        'valor': double.parse(_valorController.text),
      });

      _nomeController.clear();
      _valorController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serviço salvo com sucesso!')),
      );

      _carregarServicos();
    }
  }

  Future<void> _excluirServico(int id) async {
    await _dbService.deleteServico(id);
    _carregarServicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Serviços')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: InputDecoration(labelText: 'Nome do serviço'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O nome do serviço é obrigatório';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _valorController,
                    decoration: InputDecoration(labelText: 'Valor (R\$)'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O valor é obrigatório';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Insira um valor numérico válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _salvarServico,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    child: Text('Salvar Serviço', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: _servicos.isEmpty
                  ? Center(child: Text('Nenhum serviço cadastrado'))
                  : ListView.builder(
                itemCount: _servicos.length,
                itemBuilder: (context, index) {
                  final servico = _servicos[index];
                  return Card(
                    child: ListTile(
                      title: Text(servico['nome']),
                      subtitle: Text('R\$ ${servico['valor'].toStringAsFixed(2)}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _excluirServico(servico['id']),
                      ),
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