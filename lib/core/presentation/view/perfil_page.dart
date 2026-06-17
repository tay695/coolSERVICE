import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/core/widgets/menu_inferior.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  final Funcionario funcionario;
  const PerfilPage({super.key, required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inicial = funcionario.name.isNotEmpty
        ? funcionario.name[0].toUpperCase()
        : '?';
    final cargo = funcionario.role == UserRole.admin
        ? 'Administrador'
        : 'Funcionário';

    return Scaffold(
      backgroundColor: isDark ? AppColors.noiteArtica : AppColors.brancoGelo,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brancoPuro,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header com avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.azulProfundo, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.cianoFrio,
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brancoPuro,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  funcionario.name,
                  style: const TextStyle(
                    color: AppColors.brancoPuro,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cianoFrio.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cargo,
                    style: const TextStyle(
                      color: AppColors.brancoPuro,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _secaoTitulo('Informações Pessoais'),
          _infoCard(isDark, [
            _infoItem(Icons.person_outline, 'Nome', funcionario.name),
            _infoItem(Icons.badge_outlined, 'CPF', funcionario.cpf),
            _infoItem(Icons.phone_outlined, 'Telefone', funcionario.phone),
          ]),
          const SizedBox(height: 16),

          _secaoTitulo('Dados Profissionais'),
          _infoCard(isDark, [
            _infoItem(Icons.handyman_outlined, 'Especialidade', funcionario.especialty),
            _infoItem(Icons.work_outline, 'Cargo', cargo),
            _infoItem(Icons.account_circle_outlined, 'Usuário', funcionario.username),
            _infoItem(
              Icons.circle,
              'Status',
              funcionario.isActive ? 'Ativo' : 'Inativo',
              valueColor: funcionario.isActive ? Colors.green : Colors.red,
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: MenuInferior(
        funcionario: funcionario,
        currentIndex: 3,
      ),
    );
  }

  Widget _secaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        titulo.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _infoCard(bool isDark, List<Widget> items) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.azulProfundo : AppColors.brancoPuro,
      child: Column(children: items),
    );
  }

  Widget _infoItem(IconData icon, String label, String value, {Color? valueColor}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.azulGelo),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: valueColor,
        ),
      ),
    );
  }
}