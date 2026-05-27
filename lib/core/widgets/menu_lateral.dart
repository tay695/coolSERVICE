import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/core/presentation/view/dashboard_page.dart';
import 'package:coolservice/freatures/clientes/presentation/view/client_list_page.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_form_page.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_list_page.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view/ordem_servico_form_page.dart';
import 'package:coolservice/freatures/servico/presentation/view/service_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuLateral extends StatelessWidget {
  final Funcionario funcionario;
  const MenuLateral({super.key, required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final configViewModel = context.watch<AppConfigViewModel>();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 12, 8, 8),
              child: Icon(Icons.build, size: 35, color: Color.fromARGB(255, 255, 255, 255)),
            ),
            accountName: const Text(
              'CoolService ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('coolservice@gmail.com'),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DashboardPage(funcionario: funcionario),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClientListPage(funcionario: funcionario),
                ),
              );
            },
          ),

          // Item: Funcionários
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Funcionários'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => FuncionarioListPage(funcionario: funcionario)),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.handyman),
            title: const Text('Serviços'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceListPage(funcionario: funcionario),
                ),
              );
            },
          ),

          // Item: Ordens de Serviço
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Ordens de Serviço'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdemServicoFormPage()),
              );
            },
          ),

          const Divider(),

          SwitchListTile(
            secondary: Icon(
              configViewModel.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Modo Escuro'),
            value: configViewModel.isDarkMode,
            onChanged: (bool value) {
              configViewModel.toggleTheme(value);
            },
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'CoolService v1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
