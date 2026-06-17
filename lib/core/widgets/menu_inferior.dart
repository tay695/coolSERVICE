import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/core/presentation/view/dashboard_page.dart';
import 'package:coolservice/freatures/clientes/presentation/view/client_list_page.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_list_page.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view/ordem_servico_list_page.dart';
import 'package:coolservice/freatures/servico/presentation/view/service_list_page.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/login_page.dart';
import 'package:coolservice/core/presentation/view/perfil_page.dart';
import 'package:coolservice/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CadastrosHubPage extends StatelessWidget {
  final Funcionario funcionario;
  const CadastrosHubPage({super.key, required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = funcionario.role == UserRole.admin;

    return Scaffold(
      backgroundColor: isDark ? AppColors.noiteArtica : AppColors.brancoGelo,
      appBar: AppBar(
        title: const Text('Painel de Cadastros'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brancoPuro,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHubCard(
            context,
            icon: Icons.people,
            title: 'Clientes',
            subtitle: 'Gerenciar e cadastrar clientes',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClientListPage(funcionario: funcionario),
                ),
              );
            },
          ),
          if (isAdmin) ...[
            const SizedBox(height: 12),
            _buildHubCard(
              context,
              icon: Icons.badge,
              title: 'Funcionários',
              subtitle: 'Controle de técnicos e administradores',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        FuncionarioListPage(funcionario: funcionario),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 12),
          _buildHubCard(
            context,
            icon: Icons.handyman,
            title: 'Serviços Prestados',
            subtitle: 'Tabela de preços e tipos de serviços',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ServiceListPage(funcionario: funcionario),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MenuInferior(
        funcionario: funcionario,
        currentIndex: 1,
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.azulProfundo : AppColors.brancoPuro,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.azulGelo),
        onTap: onTap,
      ),
    );
  }
}

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
        title: const Text('Configurações'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brancoPuro,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PerfilPage(funcionario: funcionario),
              ),
            ),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? AppColors.azulProfundo : AppColors.brancoPuro,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.cianoFrio,
                      child: Text(
                        funcionario.name.isNotEmpty
                            ? funcionario.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brancoPuro,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            funcionario.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            funcionario.role == UserRole.admin
                                ? 'Administrador'
                                : 'Funcionário',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.azulGelo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.azulGelo),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Aparência',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isDark ? AppColors.azulProfundo : AppColors.brancoPuro,
            child: SwitchListTile(
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
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sessão',
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isDark ? AppColors.azulProfundo : AppColors.brancoPuro,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sair da Conta',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
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
        destino = CadastrosHubPage(funcionario: funcionario);
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destino),
    );
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
          icon: Icon(Icons.app_registration_outlined),
          selectedIcon: Icon(Icons.app_registration, color: AppColors.cianoFrio),
          label: 'Cadastros',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment, color: AppColors.cianoFrio),
          label: 'OS',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: AppColors.cianoFrio),
          label: 'Config',
        ),
      ],
    );
  }
}