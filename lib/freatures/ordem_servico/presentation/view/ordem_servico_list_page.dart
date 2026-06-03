import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/core/widgets/menu_inferior.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entidades/ordem_servico.dart';
import 'ordem_servico_form_page.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';

class OrdemServicoListPage extends StatefulWidget {
  final Funcionario funcionario;

  const OrdemServicoListPage({super.key, required this.funcionario});

  @override
  State<OrdemServicoListPage> createState() => _OrdemServicoListPageState();
}

class _OrdemServicoListPageState extends State<OrdemServicoListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdemServicoViewModel>().carregarOrdens();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrdemServicoViewModel>();
    final listOS = viewModel.ordens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Ordens de Serviço'), centerTitle: true),
      bottomNavigationBar: MenuInferior(
        currentIndex: 2,
        funcionario: widget.funcionario,
      ),
      body: listOS.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_late_rounded,
                    size: 64,
                    color: AppColors.azulGelo.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma OS cadastrada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.azulProfundo,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Toque no botão "+" para abrir uma nova.',
                    style: TextStyle(fontSize: 13, color: AppColors.cinzaNeve),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listOS.length,
              itemBuilder: (context, index) {
                final os = listOS[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.azulProfundo.withOpacity(0.4)
                        : AppColors.brancoPuro,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.azulGelo.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrdemServicoFormPage(osParaEditar: os),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'OS #${os.id.substring(os.id.length - 5)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                              _buildBadge(os.tipoAtendimento),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //  Status do Serviço
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.azulProfundo.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  os.status.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.azulProfundo,
                                  ),
                                ),
                              ),
                              //  Pagamento
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: os.isPaid
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  os.isPaid ? 'PAGO' : 'PAGAMENTO PENDENTE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: os.isPaid
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                os.isExternal
                                    ? ' Serviço Externo'
                                    : 'Atendimento Interno',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'R\$ ${os.totalValue.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.cianoFrio,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brancoPuro,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrdemServicoFormPage()),
          );
        },
      ),
    );
  }

  Widget _buildBadge(TipoAtendimento tipo) {
    Color color;
    String label;

    switch (tipo) {
      case TipoAtendimento.manutencao:
        color = Colors.orange;
        label = 'Manutenção';
        break;
      case TipoAtendimento.instalacao:
        color = AppColors.primary;
        label = 'Instalação';
        break;
      case TipoAtendimento.visitaTecnica:
        color = AppColors.cianoFrio;
        label = 'Visita Técnica';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
