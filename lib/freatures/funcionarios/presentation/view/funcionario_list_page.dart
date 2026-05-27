import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_form_page.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/core/widgets/menu_lateral.dart';

import 'package:coolservice/core/theme/app_theme.dart';

class FuncionarioListPage extends StatefulWidget {
  final Funcionario funcionario;
  const FuncionarioListPage({super.key, required this.funcionario});

  @override
  State<FuncionarioListPage> createState() => _FuncionarioListPageState();
}

class _FuncionarioListPageState extends State<FuncionarioListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FuncionarioViewModel>().listAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final funcionario = widget.funcionario;
    final viewModel = context.watch<FuncionarioViewModel>();
    final isAdmin = funcionario.role == UserRole.admin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.noiteArtica : AppColors.brancoGelo,
      appBar: AppBar(
        title: const Text('Funcionários'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.brancoPuro,
        elevation: 0,
      ),
      drawer: MenuLateral(funcionario: funcionario),
      body: Column(
        children: [
          // Header
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
                  hintText: 'Buscar por nome ou CPF...',
                  hintStyle: TextStyle(color: AppColors.azulGelo.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.azulGelo),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => viewModel.searchFuncionario(value),
              ),
            ),
          ),

          // Contagem
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  '${viewModel.funcionarios.length} funcionário(s)',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.cinzaNeve : AppColors.azulProfundo,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: viewModel.funcionarios.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.badge_outlined, size: 64, color: AppColors.cinzaNeve.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('Nenhum funcionário encontrado',
                            style: TextStyle(color: AppColors.cinzaNeve, fontSize: 15)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: viewModel.funcionarios.length,
                    itemBuilder: (context, index) {
                      final f = viewModel.funcionarios[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.azulProfundo.withOpacity(0.4) : AppColors.brancoPuro,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.azulGelo.withOpacity(0.3)),
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
                                  color: AppColors.primary.withOpacity(0.12),
                                  border: Border.all(color: AppColors.azulGelo.withOpacity(0.4)),
                                ),
                                child: Center(
                                  child: Text(
                                    f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: AppColors.primary,
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
                                      f.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: isDark ? AppColors.brancoPuro : AppColors.noiteArtica,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      f.especialty,
                                      style: const TextStyle(fontSize: 12, color: AppColors.cinzaNeve),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: f.role == UserRole.admin
                                            ? AppColors.cianoFrio.withOpacity(0.15)
                                            : AppColors.azulGelo.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: f.role == UserRole.admin
                                              ? AppColors.cianoFrio.withOpacity(0.4)
                                              : AppColors.azulGelo.withOpacity(0.4),
                                        ),
                                      ),
                                      child: Text(
                                        f.role == UserRole.admin ? 'Administrador' : 'Funcionário',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: f.role == UserRole.admin
                                              ? AppColors.cianoFrio
                                              : AppColors.azulGelo,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Ações
                              Column(
                                children: [
                                  Switch(
                                    value: f.isActive,
                                    activeColor: AppColors.active,
                                    inactiveThumbColor: AppColors.inactive,
                                    onChanged: (value) => viewModel.toggleActive(f.id, value),
                                  ),
                                  if (isAdmin)
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FuncionarioFormPage(funcionario: f),
                                        ),
                                      ).then((_) => context.read<FuncionarioViewModel>().listAll()),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                      ),
                                    ),
                                ],
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
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.cianoFrio,
              foregroundColor: AppColors.noiteArtica,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FuncionarioFormPage()),
              ).then((_) => context.read<FuncionarioViewModel>().listAll()),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Novo funcionário', style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }
}