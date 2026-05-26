import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/freatures/servico/presentation/view/service_list_page.dart';
import 'package:coolservice/core/presentation/view/dashboard_page.dart';
import 'package:coolservice/freatures/clientes/presentation/view/client_form_page.dart';
import 'package:coolservice/freatures/clientes/presentation/view/client_list_page.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_form_page.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';

class MenuLateral extends StatelessWidget {
   final Funcionario funcionario;
    const MenuLateral({super.key, required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final isAdmin = funcionario.role == UserRole.admin;
    // Escuta a ViewModel global para saber se o Modo Escuro está ativo
    final configViewModel = context.watch<AppConfigViewModel>();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.build, size: 35, color: Colors.blue),
            ),
            accountName: const Text(
              'CoolService App',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('sprint2_v1.0@coolservice.com'),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),

          //  Início
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => DashboardPage(funcionario: funcionario)),
              );
            },
          ),

          //  Clientes
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ClientListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Adicionar clientes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ClientFormPage()),
              );
            },
          ),

          // Item: Funcionários
           ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Funcionários'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) =>
                        FuncionarioListPage(funcionario: funcionario)),
              );
            },
          ),
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.person_add_alt_1),
              title: const Text('Adicionar funcionário'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const FuncionarioFormPage()),
                );
              },
            ),

         


          // Item: Serviços
          ListTile(
            leading: const Icon(Icons.handyman),
            title: const Text('Serviços'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServiceListPage()),
              );
            },
          ),
           if (isAdmin)
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Adicionar serviço'),
              onTap: () {
                Navigator.pop(context);
              },
            ),


          // Item: Ordens de Serviço
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Ordens de Serviço'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

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
