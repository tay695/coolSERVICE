import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/core/presentation/view/dashboard_page.dart';
import 'package:coolservice/freatures/clientes/presentation/view/client_list_page.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_list_page.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view/ordem_servico_list_page.dart';
import 'package:coolservice/freatures/servico/presentation/view/service_list_page.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/login_page.dart';
import 'package:coolservice/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// tELA DE CONFIGURAÇÕES
class ConfiguracoesPage extends StatelessWidget {
  final Funcionario funcionario;
  const ConfiguracoesPage({super.key, required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final configViewModel = context.watch<AppConfigViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.noiteArtica : AppColors.brancoGelo,
      appBar: AppBar(
        title: const Text('controles de serviços e funcionários'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brancoPuro,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.badge, color: AppColors.primary),
            title: const Text('Funcionários da empresa'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FuncionarioListPage(funcionario: funcionario),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.handyman, color: AppColors.primary),
            title: const Text('Serviços prestados'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ServiceListPage(funcionario: funcionario),
                ),
              );
            },
          ),
          const Divider(height: 32),

          SwitchListTile(
            secondary: Icon(
              configViewModel.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: const Text('Modo Escuro'),
            value: configViewModel.isDarkMode,
            onChanged: (bool value) {
              configViewModel.toggleTheme(value);
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair da Conta',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MenuInferior(
        funcionario: funcionario,
        currentIndex: 3,
      ),
    );
  }
}

/// --- BARRA DE NAVEGAÇÃO DO RODAPÉ ---
class MenuInferior extends StatelessWidget {
  final Funcionario funcionario;
  final int currentIndex;

  const MenuInferior({
    super.key,
    required this.funcionario,
    required this.currentIndex,
  });

  void _executarNavegacao(BuildContext context, int index) {
    if (index == currentIndex) return;
    Widget destino;
    switch (index) {
      case 0:
        destino = DashboardPage(funcionario: funcionario);
        break;
      case 1:
        destino = ClientListPage(funcionario: funcionario);
        break;
      case 2:
        destino = OrdemServicoListPage(funcionario: funcionario);
        break;
      case 3:
        destino = ConfiguracoesPage(funcionario: funcionario);
        break;
      default:
        destino = DashboardPage(funcionario: funcionario);
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => destino));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NavigationBar(
      selectedIndex: currentIndex,
      backgroundColor: isDark ? AppColors.azulProfundo : AppColors.brancoPuro,
      indicatorColor: AppColors.cianoFrio.withOpacity(0.2),
      onDestinationSelected: (index) => _executarNavegacao(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: AppColors.cianoFrio),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people, color: AppColors.cianoFrio),
          label: 'Clientes',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment, color: AppColors.cianoFrio),
          label: 'Ordens',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: AppColors.cianoFrio),
          label: 'Serv/Funci',
        ),
      ],
    );
  }
}
