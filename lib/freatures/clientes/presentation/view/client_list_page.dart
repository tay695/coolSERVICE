import 'package:coolservice/core/widgets/menu_lateral.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/clientes/presentation/view/client_form_page.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coolservice/core/theme/app_theme.dart';

class ClientListPage extends StatefulWidget {
  final Funcionario funcionario;
  const ClientListPage({super.key, required this.funcionario});

  @override
  State<ClientListPage> createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ClientViewModel>().listAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final funcionario = widget.funcionario;
    final viewModel = context.watch<ClientViewModel>();
    final osViewModel = context.watch<OrdemServicoViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.noiteArtica : AppColors.brancoGelo,
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brancoPuro,
        elevation: 0,
      ),
      drawer: MenuLateral(funcionario: funcionario),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.brancoPuro.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.azulGelo.withOpacity(0.3)),
              ),
              child: TextField(
                style: const TextStyle(color: AppColors.brancoPuro),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome, CPF/CNPJ ou telefone...',
                  hintStyle: TextStyle(
                    color: AppColors.azulGelo.withOpacity(0.7),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.azulGelo,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) => viewModel.searchClient(value),
              ),
            ),
          ),

          // Contagem
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  '${viewModel.clients.length} cliente(s)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.cinzaNeve
                        : AppColors.azulProfundo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: viewModel.clients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: AppColors.cinzaNeve.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum cliente encontrado',
                          style: TextStyle(
                            color: AppColors.cinzaNeve,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: viewModel.clients.length,
                    itemBuilder: (context, index) {
                      final c = viewModel.clients[index];

                      final temPendencia = osViewModel.clientePossuiPendencia(
                        c.id,
                      );
                      final valorDevendo = osViewModel
                          .calcularDividaTotalDoCliente(c.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.azulProfundo.withOpacity(0.4)
                              : AppColors.brancoPuro,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: temPendencia
                                ? Colors.red.withOpacity(0.3)
                                : AppColors.azulGelo.withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: temPendencia
                                      ? Colors.red.withOpacity(0.1)
                                      : AppColors.cianoFrio.withOpacity(0.12),
                                  border: Border.all(
                                    color: temPendencia
                                        ? Colors.red.withOpacity(0.4)
                                        : AppColors.cianoFrio.withOpacity(0.3),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    c.name.isNotEmpty
                                        ? c.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: temPendencia
                                          ? Colors.red
                                          : AppColors.cianoFrio,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.brancoPuro
                                            : AppColors.noiteArtica,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.cpfCnpj,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.cinzaNeve,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.phone,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.cinzaNeve,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    _buildStatusFinanceiroBadge(
                                      temPendencia,
                                      valorDevendo,
                                    ),
                                  ],
                                ),
                              ),
                              // Editar
                              GestureDetector(
                                onTap: () =>
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ClientFormPage(client: c),
                                      ),
                                    ).then(
                                      (_) => context
                                          .read<ClientViewModel>()
                                          .listAll(),
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.cianoFrio.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: AppColors.cianoFrio,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.cianoFrio,
        foregroundColor: AppColors.noiteArtica,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientFormPage()),
        ).then((_) => context.read<ClientViewModel>().listAll()),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text(
          'Novo cliente',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildStatusFinanceiroBadge(bool temPendencia, double valorDevendo) {
    if (temPendencia) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.red.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 12,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              'Pendente: R\$ ${valorDevendo.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 12,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            const Text(
              'Em dia',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    }
  }
}
