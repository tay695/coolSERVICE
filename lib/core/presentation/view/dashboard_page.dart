import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/core/widgets/menu_lateral.dart';

class DashboardPage extends StatelessWidget {
  final Funcionario funcionario;

  const DashboardPage({super.key, required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrdemServicoViewModel>();
    final ordens = viewModel.ordens;

    return Scaffold(
      appBar: AppBar(title: const Text('CoolService ')),
      drawer: MenuLateral(funcionario: funcionario),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              ' Ordens de Serviço',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ordens.isEmpty
                  ? _buildEmptyState()
                  : _buildDashboardGrid(ordens),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma Ordem de Serviço registrada.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Cadastre uma nova OS para ver as estatísticas.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(List<OrdemServico> ordens) {
    final qtdAbertas = ordens
        .where((os) => os.status == OrderStatus.open)
        .length;
    final qtdAndamento = ordens
        .where((os) => os.status == OrderStatus.inProgress)
        .length;
    final qtdConcluidas = ordens
        .where((os) => os.status == OrderStatus.completed)
        .length;
    final qtdPendentes = ordens
        .where((os) => os.status == OrderStatus.paymentPending)
        .length;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatusCard(
          'Abertas',
          qtdAbertas.toString(),
          AppColors.statusOpen,
          Icons.lock_open,
        ),
        _buildStatusCard(
          'Em Andamento',
          qtdAndamento.toString(),
          AppColors.statusInProgress,
          Icons.loop,
        ),
        _buildStatusCard(
          'Concluídas',
          qtdConcluidas.toString(),
          AppColors.statusCompleted,
          Icons.check_circle,
        ),
        _buildStatusCard(
          'Pgto. Pendente',
          qtdPendentes.toString(),
          AppColors.statusPaymentPending,
          Icons.error_outline,
        ),
      ],
    );
  }

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
