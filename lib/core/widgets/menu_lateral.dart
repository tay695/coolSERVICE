import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
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

          // Item: Dashboard / Início
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Início'),
            onTap: () {
              Navigator.pop(context); // Fecha o menu lateral
              // Aqui você adicionaria a navegação para a home se necessário
            },
          ),

          // Item: Clientes
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Clientes'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/clientes');
            },
          ),

          // Item: Funcionários
          ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Funcionários'),
            onTap: () {
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/funcionarios');
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

          const Divider(), // Linha divisória estética
          // Item Especial: Switch do Modo Escuro integrado ao SharedPreferences
          SwitchListTile(
            secondary: Icon(
              configViewModel.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            title: const Text('Modo Escuro'),
            value: configViewModel.isDarkMode,
            onChanged: (bool value) {
              // Executa a função da ViewModel que salva no SharedPreferences
              configViewModel.toggleTheme(value);
            },
          ),

          const Spacer(), // Empurra o rodapé para o final da tela
          // Versão do App no Rodapé
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
