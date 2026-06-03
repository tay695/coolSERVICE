import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/freatures/clientes/domain/entidades/cliente.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientProfilePage extends StatelessWidget {
  final Client cliente;
  final Funcionario funcionarioLogado;

  const ClientProfilePage({
    super.key,
    required this.cliente,
    required this.funcionarioLogado,
  });

  @override
  Widget build(BuildContext context) {
    final osViewModel = context.watch<OrdemServicoViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Busca só as ordens desse cliente
    final ordensDoCliente = osViewModel.buscarOrdensDoCliente(cliente.id);
    final valorDevendo = osViewModel.calcularDividaTotalDoCliente(cliente.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Cliente')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? AppColors.azulProfundo : AppColors.brancoPuro,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.cianoFrio.withOpacity(0.2),
                      child: Text(
                        cliente.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.cianoFrio,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cliente.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Doc: ${cliente.cpfCnpj}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Tel: ${cliente.phone}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (valorDevendo > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Débito Pendente: R\$ ${valorDevendo.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Ordens de serviços realizadas (${ordensDoCliente.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ordensDoCliente.isEmpty
                ? const Center(
                    child: Text('Nenhuma ordem de serviço para este cliente.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ordensDoCliente.length,
                    itemBuilder: (context, index) {
                      final os = ordensDoCliente[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                'OS #${os.id} - ${os.tipoAtendimento.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Valor Total: R\$ ${os.totalValue.toStringAsFixed(2)}',
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: os.isPaid
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  os.isPaid ? 'PAGO' : 'PENDENTE',
                                  style: TextStyle(
                                    color: os.isPaid
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),

                            if (funcionarioLogado.role == UserRole.admin)
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black12
                                      : Colors.grey[50],
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                                child: SwitchListTile(
                                  dense: true,
                                  title: const Text(
                                    'Confirmar Recebimento',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  value: os.isPaid,
                                  activeColor: Colors.green,
                                  onChanged: (bool pago) {
                                    // Chama a função que criamos no Passo 2!
                                    osViewModel.alternarStatusPagamento(
                                      os,
                                      pago,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
