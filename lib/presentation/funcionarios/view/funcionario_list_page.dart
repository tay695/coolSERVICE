import 'package:coolservice/domain/entidades/funcionarios.dart';
import 'package:coolservice/presentation/funcionarios/view_model/funcionario_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FuncionarioListPage extends StatelessWidget {
  const FuncionarioListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FuncionarioViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Funcionários')),
      body: ListView.builder(
        itemCount: viewModel.funcionarios.length,
        itemBuilder: (context, index) {
          final f = viewModel.funcionarios[index];
          return ListTile(
            title: Text(f.name),
            subtitle: Text(f.role.name),
            trailing: Icon(
              Icons.circle,
              color: f.isActive ? Colors.green : Colors.red,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final novo = Funcionario(
            id: DateTime.now().toString(),
            name: 'Técnico Novo',
            cpf: '123',
            especialty: 'Ar Condicionado',
            phone: '999',
            role: UserRole.funcionario,
            isActive: true,
          );
          viewModel.createFuncionario(novo);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
