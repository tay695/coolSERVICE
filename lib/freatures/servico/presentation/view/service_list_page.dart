import 'package:coolservice/core/widgets/menu_lateral.dart';
import 'package:coolservice/freatures/servico/presentation/view/service_form_page.dart';
import 'package:coolservice/freatures/servico/presentation/view_model/Service_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceListPage extends StatefulWidget {
  const ServiceListPage({super.key});

  @override
  State<ServiceListPage> createState() => _ServiceListPageState();
}

class _ServiceListPageState extends State<ServiceListPage> {
  @override
  void initState() {
    super.initState();
    // Carrega os serviços quando a página é inicializada
    Future.microtask(() {
      context.read<ServiceViewModel>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ServiceViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Serviços')),
      drawer: const MenuLateral(),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.handyman,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum serviço cadastrado',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ServiceFormPage(),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Serviço'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: viewModel.services.length,
                  itemBuilder: (context, index) {
                    final service = viewModel.services[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(service.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(service.description),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${service.basePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              service.tipoAtendimento.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Editar'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ServiceFormPage(service: service),
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              child: const Text(
                                'Deletar',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: Text(
                                      'Deseja excluir o serviço "${service.name}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          viewModel.deleteService(service.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Deletar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServiceFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
