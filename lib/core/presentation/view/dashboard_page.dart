import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/core/widgets/menu_lateral.dart';
import 'package:flutter/material.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';

class DashboardPage extends StatelessWidget {
  final Funcionario funcionario; 
  const DashboardPage({super.key, required this.funcionario});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CoolService Dashboard')),
      drawer: MenuLateral(funcionario: funcionario),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo das Ordens de Serviço',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatusCard(
                    'Abertas',
                    '5',
                    AppColors.statusOpen,
                    Icons.lock_open,
                  ),
                  _buildStatusCard(
                    'Em Andamento',
                    '3',
                    AppColors.statusInProgress,
                    Icons.loop,
                  ),
                  _buildStatusCard(
                    'Concluídas',
                    '12',
                    AppColors.statusCompleted,
                    Icons.check_circle,
                  ),
                  _buildStatusCard(
                    'Pgto. Pendente',
                    '2',
                    AppColors.statusPaymentPending,
                    Icons.error_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // construção dos cards
  Widget _buildStatusCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
