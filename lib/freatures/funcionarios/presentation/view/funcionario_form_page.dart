
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FuncionarioFormPage extends StatefulWidget {
  final Funcionario? funcionario;
  const FuncionarioFormPage({super.key, this.funcionario});

  @override
  State<FuncionarioFormPage> createState() => _FuncionarioFormPageState();
}

class _FuncionarioFormPageState extends State<FuncionarioFormPage> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _especialidadeController = TextEditingController();
  final _phoneController = TextEditingController();
  UserRole _selectedRole = UserRole.funcionario;

  @override
  void initState() {
    super.initState();
    if (widget.funcionario != null) {
      _nomeController.text = widget.funcionario!.name;
      _cpfController.text = widget.funcionario!.cpf;
      _especialidadeController.text = widget.funcionario!.especialty;
      _phoneController.text = widget.funcionario!.phone;
      _selectedRole = widget.funcionario!.role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<FuncionarioViewModel>();
    final isEditing = widget.funcionario != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Funcionário' : 'Novo Funcionário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _cpfController,
              decoration: const InputDecoration(labelText: 'CPF'),
            ),
            TextField(
              controller: _especialidadeController,
              decoration: const InputDecoration(labelText: 'Especialidade'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Cargo'),
              items: UserRole.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final username = viewModel.generateUsername(
                  _nomeController.text,
                  _phoneController.text,
                );
                final password = viewModel.generatePassword(
                  _cpfController.text,
                );
                final funcionario = Funcionario(
                  id: widget.funcionario?.id ?? DateTime.now().toString(),
                  name: _nomeController.text,
                  cpf: _cpfController.text,
                  especialty: _especialidadeController.text,
                  phone: _phoneController.text,
                  role: _selectedRole,
                  isActive: widget.funcionario?.isActive ?? true,
                  username: widget.funcionario?.username ?? username,
                  passwordHash: widget.funcionario?.passwordHash ?? password,
                );
                if (isEditing) {
                  await viewModel.updateFuncionario(funcionario);
                } else {
                  await viewModel.createFuncionario(funcionario);
                }

                if (!isEditing) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login: $username | Senha: $password'),
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Salvar' : 'Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
