import 'package:coolservice/domain/entidades/funcionarios.dart';
import 'package:coolservice/presentation/funcionarios/view_model/funcionario_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coolservice/presentation/funcionarios/view/funcionario_form_page.dart';

class FuncionarioListPage extends StatelessWidget {
  const FuncionarioListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FuncionarioViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Funcionários')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nome ou CPF',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => viewModel.searchFuncionario(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.funcionarios.length,
              itemBuilder: (context, index) {
                final f = viewModel.funcionarios[index];
                return ListTile(
                  title: Text(f.name),
                  subtitle: Text('${f.especialty} — ${f.cpf}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        color: f.isActive ? Colors.green : Colors.red,
                        size: 12,
                      ),
                      Switch(
                        value: f.isActive,
                        onChanged: (value) =>
                            viewModel.toggleActive(f.id, value),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FuncionarioFormPage(funcionario: f),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FuncionarioFormPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}