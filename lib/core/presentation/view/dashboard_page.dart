import 'package:coolservice/core/widgets/menu_inferior.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view/ordem_servico_form_page.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolservice/core/services/notification_service.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class DashboardPage extends StatefulWidget {
  final Funcionario funcionario;

  const DashboardPage({super.key, required this.funcionario});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  OrderStatus? _filtroAtivo;
  final ScrollController _tabsScrollController = ScrollController();
  StreamSubscription? _osListener;

  @override
  void initState() {
    super.initState();
    _iniciarListenerOS();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FuncionarioViewModel>().listAllFromFirestore();
      final isAdmin = widget.funcionario.role == UserRole.admin;
      context.read<OrdemServicoViewModel>().carregarOrdensPorFuncionario(
        widget.funcionario.id,
        isAdmin: isAdmin,
      );
    });
  }

  void _iniciarListenerOS() {
    final funcionarioId = widget.funcionario.id;
    bool primeiraLeitura = true;

    _osListener = FirebaseFirestore.instance
        .collection('ordens_servico')
        .where('employeeId', isEqualTo: funcionarioId)
        .snapshots()
        .listen((snapshot) {
          if (primeiraLeitura) {
            primeiraLeitura = false;
            return;
          }
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              NotificationService.showLocalNotification(
                RemoteMessage(
                  notification: RemoteNotification(
                    title: 'Nova Ordem de Serviço',
                    body: 'Você foi alocado em uma nova OS.',
                  ),
                ),
              );
            }
          }
        });
  }

  static const _statusConfig = {
    OrderStatus.aberto: _StatusConfig(
      label: 'Em aberto',
      color: Color(0xFF378ADD),
      bgColor: Color(0xFFE6F1FB),
      textColor: Color(0xFF0C447C),
      icon: Icons.lock_open_outlined,
    ),
    OrderStatus.encaminhada: _StatusConfig(
      label: 'Em andamento',
      color: Color(0xFF1D9E75),
      bgColor: Color(0xFFE1F5EE),
      textColor: Color(0xFF085041),
      icon: Icons.loop_outlined,
    ),
    OrderStatus.pedentes: _StatusConfig(
      label: 'Pgto. pendente',
      color: Color(0xFFBA7517),
      bgColor: Color(0xFFFAEEDA),
      textColor: Color(0xFF633806),
      icon: Icons.schedule_outlined,
    ),
    OrderStatus.completo: _StatusConfig(
      label: 'Concluídas',
      color: Color(0xFF639922),
      bgColor: Color(0xFFEAF3DE),
      textColor: Color(0xFF27500A),
      icon: Icons.check_circle_outline,
    ),
  };

  @override
  void dispose() {
    _osListener?.cancel();
    _tabsScrollController.dispose();
    super.dispose();
  }

  void _animarRolagemAba(int index) {
    if (_tabsScrollController.hasClients) {
      double posicaoDestino = index * 95.0;
      final maxScroll = _tabsScrollController.position.maxScrollExtent;

      if (posicaoDestino > maxScroll) {
        posicaoDestino = maxScroll;
      }

      _tabsScrollController.animateTo(
        posicaoDestino,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<OrdemServicoViewModel>();

    // filtro para o usuario
    final isAdmin = widget.funcionario.role == UserRole.admin;
    final ordensDoUsuario = isAdmin
        ? viewModel.ordens
        : viewModel.ordens
              .where(
                (os) =>
                    os.employeeId == widget.funcionario.id ||
                    os.technicianId == widget.funcionario.id,
              )
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('CoolService')),
      bottomNavigationBar: MenuInferior(
        funcionario: widget.funcionario,
        currentIndex: 0,
      ),
      body: ordensDoUsuario.isEmpty
          ? _buildEmptyState()
          : _buildDashboard(ordensDoUsuario),
    );
  }

  Widget _buildEmptyState() {
    return  Center(
       child: Semantics(
        label: 'Nenhuma ordem de serviço registrada. As ordens destinadas a você aparecerão aqui.',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma Ordem de Serviço registrada.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'As ordens destinadas a você aparecerão aqui.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
       ),
    );
  }

  Widget _buildDashboard(List<OrdemServico> ordens) {
    final ordensFiltradasPeloStatus = _filtroAtivo == null
        ? ordens
        : ordens.where((os) => os.status == _filtroAtivo).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIndicadores(ordens),
        _buildFiltroTabs(),
        const Divider(height: 1),
        Expanded(child: _buildListaOS(ordensFiltradasPeloStatus)),
      ],
    );
  }

  Widget _buildIndicadores(List<OrdemServico> ordens) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.3,
        children: _statusConfig.entries.map((entry) {
          final count = ordens.where((os) => os.status == entry.key).length;
          final isAtivo = _filtroAtivo == entry.key;
          final cfg = entry.value;

          return GestureDetector(
            onTap: () {
              setState(() {
                _filtroAtivo = isAtivo ? null : entry.key;
              });
              final mapaIndexes = {
                OrderStatus.aberto: 1,
                OrderStatus.encaminhada: 2,
                OrderStatus.pedentes: 3,
                OrderStatus.completo: 4,
              };
              _animarRolagemAba(isAtivo ? 0 : (mapaIndexes[entry.key] ?? 0));
            },
            child: Semantics(
    label: '${cfg.label}, $count ordens. ${isAtivo ? 'Filtro ativo' : 'Toque para filtrar'}',
    button: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: cfg.bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isAtivo ? cfg.color : cfg.color.withOpacity(0.25),
                  width: isAtivo ? 1.5 : 0.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cfg.color,
                    ),
                  ),
              
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cfg.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: cfg.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: cfg.textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFiltroTabs() {
    final tabs = [
      (null, 'Todas'),
      (OrderStatus.aberto, 'Em aberto'),
      (OrderStatus.encaminhada, 'Em andamento'),
      (OrderStatus.pedentes, 'Pendente'),
      (OrderStatus.completo, 'Concluídas'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        controller: _tabsScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (status, label) = tabs[i];
          final isAtivo = _filtroAtivo == status;

          return GestureDetector(
            onTap: () {
              setState(() => _filtroAtivo = status);
              _animarRolagemAba(i);
            },
            child: Semantics(
              label: '$label${isAtivo ? ', selecionado' : ''}',
              button: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isAtivo
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isAtivo
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withOpacity(0.35),
                  width: 0.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isAtivo
                      ? Colors.white
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListaOS(List<OrdemServico> ordens) {
    if (ordens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Nenhuma ordem nesta categoria.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ordens.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _buildOSItem(ordens[i]),
    );
  }

  Widget _buildOSItem(OrdemServico os) {
    final cfg = _statusConfig[os.status]!;
    String nomeTecnico = 'Sem Técnico';

    if (os.employeeId.isNotEmpty) {
      try {
        final funcionarioViewModel = context.read<FuncionarioViewModel>();
        final tec = funcionarioViewModel.funcionarios.firstWhere(
          (f) => f.id == os.employeeId,
        );
        nomeTecnico = tec.name;
      } catch (_) {
        nomeTecnico = 'Técnico Não Encontrado';
      }
    }

    final iniciaisTecnico = _getIniciais(nomeTecnico);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrdemServicoFormPage(osParaEditar: os),
          ),
        );
      },
      child: Semantics(
        label: 'Ordem de serviço ${os.id}, técnico $nomeTecnico, status ${cfg.label}. Toque para abrir.',
        button: true,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.15), width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                iniciaisTecnico,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OS-${os.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cliente: ${os.clientId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Téc: $nomeTecnico',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cfg.bgColor,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                cfg.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: cfg.textColor,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
    
  }

  String _getIniciais(String nome) {
    final partes = nome.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final Color bgColor;
  final Color textColor;
  final IconData icon;

  const _StatusConfig({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.textColor,
    required this.icon,
  });
}
