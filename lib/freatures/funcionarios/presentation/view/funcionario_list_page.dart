import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_form_page.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coolservice/core/widgets/menu_lateral.dart';
import 'package:coolservice/core/theme/app_theme.dart';

class FuncionarioListPage extends StatelessWidget {
  const FuncionarioListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FuncionarioViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Funcionários')),
      drawer: const MenuLateral(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nome ou CPF',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => viewModel.searchFuncionario(value),
            ),
          ),

          // Lista de Funcionários
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
                        color: f.isActive
                            ? AppColors.active
                            : AppColors.inactive,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Switch(
                        value: f.isActive,
                        activeThumbColor: AppColors.active,
                        onChanged: (value) =>
                            viewModel.toggleActive(f.id, value),
                      ),

                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FuncionarioFormPage(),
                            ),
                          );
                        },
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
          MaterialPageRoute(builder: (_) => const FuncionarioFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
