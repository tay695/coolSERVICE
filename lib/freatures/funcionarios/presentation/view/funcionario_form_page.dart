import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:coolservice/core/theme/app_theme.dart';

class FuncionarioFormPage extends StatefulWidget {
  final Funcionario? funcionario;
  const FuncionarioFormPage({super.key, this.funcionario});

  @override
  State<FuncionarioFormPage> createState() => _FuncionarioFormPageState();
}

class _FuncionarioFormPageState extends State<FuncionarioFormPage> {
  final _formKey = GlobalKey<FormState>();
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

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.azulGelo, size: 20) : null,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.noiteArtica
          : AppColors.brancoPuro,
      labelStyle: const TextStyle(color: AppColors.azulProfundo, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.azulGelo, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.azulGelo, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inactive, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inactive, width: 2),
      ),
    );
  }

  Widget _buildSectionCard({required String label, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.azulProfundo.withOpacity(0.4)
            : AppColors.brancoPuro,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.azulGelo.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.azulCeu,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<FuncionarioViewModel>();
    final isEditing = widget.funcionario != null;

    return Scaffold(
  appBar: AppBar(title: Text(isEditing ? 'Editar Funcionário' : 'Novo Funcionário')),
  body: Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.azulProfundo, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.azulCeu.withOpacity(0.18),
                  border: Border.all(color: AppColors.azulGelo.withOpacity(0.4), width: 1.5),
                ),
                child: const Icon(Icons.badge_outlined, color: AppColors.brancoPuro, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                isEditing ? 'Editar funcionário' : 'Novo funcionário',
                style: const TextStyle(color: AppColors.brancoPuro, fontSize: 17, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text('Preencha os dados do funcionário',
                style: TextStyle(color: AppColors.azulGelo, fontSize: 13)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildSectionCard(
          label: 'Dados pessoais',
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: _fieldDecoration('Nome completo', icon: Icons.person_outline),
              validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cpfController,
              decoration: _fieldDecoration('CPF', icon: Icons.badge_outlined),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Informe o CPF' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: _fieldDecoration('Telefone', icon: Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Informe o telefone' : null,
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildSectionCard(
          label: 'Dados profissionais',
          children: [
            TextFormField(
              controller: _especialidadeController,
              decoration: _fieldDecoration('Especialidade', icon: Icons.build_outlined),
              validator: (v) => v!.isEmpty ? 'Informe a especialidade' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              decoration: _fieldDecoration('Cargo', icon: Icons.work_outline),
              items: [UserRole.admin, UserRole.funcionario]
                  .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r == UserRole.admin ? 'Administrador' : 'Funcionário'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
          ],
        ),

        const SizedBox(height: 24),

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.azulCeu, fontSize: 14)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.brancoPuro,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            icon: Container(
              width: 24, height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brancoPuro.withOpacity(0.18),
              ),
              child: const Icon(Icons.check_rounded, size: 16),
            ),
            label: Text(
              isEditing ? 'Salvar funcionário' : 'Cadastrar funcionário',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final username = viewModel.generateUsername(_nomeController.text, _phoneController.text);
                final password = viewModel.generatePassword(_cpfController.text);
                final passwordHash = sha256.convert(utf8.encode(password)).toString();

                final funcionario = Funcionario(
                  id: widget.funcionario?.id ?? DateTime.now().toString(),
                  name: _nomeController.text,
                  cpf: _cpfController.text,
                  especialty: _especialidadeController.text,
                  phone: _phoneController.text,
                  role: _selectedRole,
                  isActive: widget.funcionario?.isActive ?? true,
                  username: widget.funcionario?.username ?? username,
                  passwordHash: widget.funcionario?.passwordHash ?? passwordHash,
                );

                if (isEditing) {
                  await viewModel.updateFuncionario(funcionario);
                } else {
                  await viewModel.createFuncionario(funcionario);
                }

                if (!isEditing) {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => AlertDialog(
                      title: const Text('Credenciais do Funcionário'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuário: $username'),
                          const SizedBox(height: 8),
                          Text('Senha: $password'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                Navigator.pop(context);
              }
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    ),
  ),
);
  }
}