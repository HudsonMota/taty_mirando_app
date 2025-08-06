// lib/main.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- Adicione esta linha

import 'screens/clientes_screen.dart';
import 'screens/servicos_screen.dart';
import 'screens/agendamentos_screen.dart';
import 'screens/conclusao_screen.dart';
import 'screens/relatorios_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  runApp(SalaoBelezaApp());
}

class SalaoBelezaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salão de Beleza',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      // --- ALTERAÇÕES AQUI ---
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'),
      ],
      // ----------------------
      routes: {
        '/': (context) => HomeScreen(),
        '/clientes': (context) => ClientesScreen(),
        '/servicos': (context) => ServicosScreen(),
        '/agendamentos': (context) => AgendamentosScreen(),
        '/conclusao': (context) => ConclusaoScreen(),
        '/relatorios': (context) => RelatoriosScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _menu = [
    {'titulo': 'Cadastro de Clientes', 'icone': Icons.person_add, 'rota': '/clientes'},
    {'titulo': 'Cadastro de Serviços', 'icone': Icons.content_cut, 'rota': '/servicos'},
    {'titulo': 'Agendamentos', 'icone': Icons.calendar_month, 'rota': '/agendamentos'},
    {'titulo': 'Conclusão / Recibos', 'icone': Icons.receipt_long, 'rota': '/conclusao'},
    {'titulo': 'Relatórios', 'icone': Icons.bar_chart, 'rota': '/relatorios'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Salão de Beleza - Menu Principal')),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _menu.length,
        itemBuilder: (context, index) {
          final item = _menu[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(item['icone'], color: Colors.pink, size: 30),
              title: Text(item['titulo'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, item['rota']);
              },
            ),
          );
        },
      ),
    );
  }
}