import 'package:coolservice/core/widgets/menu_lateral.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/clientes/presentation/view/client_form_page.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientListPage extends StatelessWidget {
  final Funcionario funcionario;
  const ClientListPage({super.key, required this.funcionario});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClientViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      drawer: MenuLateral(funcionario: funcionario),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nome, CPF/CNPJ ou telefone',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => viewModel.searchClient(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.clients.length,
              itemBuilder: (context, index) {
                final c = viewModel.clients[index];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text('${c.cpfCnpj} — ${c.phone}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientFormPage(client: c),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
