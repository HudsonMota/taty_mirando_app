// lib/screens/clientes_screen.dart

import 'package:flutter/material.dart';
import '../database_service.dart';

class ClientesScreen extends StatefulWidget {
  @override
  _ClientesScreenState createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();

  List<Map<String, dynamic>> _clientes = [];

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await _dbService.getClientes();
    setState(() {
      _clientes = clientes;
    });
  }

  Future<void> _salvarCliente() async {
    if (_formKey.currentState!.validate()) {
      await _dbService.insertCliente({
        'nome': _nomeController.text,
        'telefone': _telefoneController.text,
        'endereco': _enderecoController.text,
      });

      _nomeController.clear();
      _telefoneController.clear();
      _enderecoController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente salvo com sucesso!')),
      );

      _carregarClientes();
    }
  }

  Future<void> _excluirCliente(int id) async {
    await _dbService.deleteCliente(id);
    _carregarClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Clientes')),
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
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _telefoneController,
                    decoration: InputDecoration(labelText: 'Telefone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O telefone é obrigatório';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _enderecoController,
                    decoration: InputDecoration(labelText: 'Endereço'),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _salvarCliente,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                    child: Text('Salvar Cliente', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: _clientes.isEmpty
                  ? Center(child: Text('Nenhum cliente cadastrado'))
                  : ListView.builder(
                itemCount: _clientes.length,
                itemBuilder: (context, index) {
                  final cliente = _clientes[index];
                  return Card(
                    child: ListTile(
                      title: Text(cliente['nome']),
                      subtitle: Text('${cliente['telefone']} - ${cliente['endereco']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _excluirCliente(cliente['id']),
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