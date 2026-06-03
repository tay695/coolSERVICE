import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';
import 'package:coolservice/freatures/servico/presentation/view_model/Service_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdemServicoFormPage extends StatefulWidget {
  // Verificação para ver se a OS será editada ou se é a criação de uma nova OS
  final OrdemServico? osParaEditar;
  const OrdemServicoFormPage({super.key, this.osParaEditar});

  @override
  State<OrdemServicoFormPage> createState() => _OrdemServicoFormPageState();
}

class _OrdemServicoFormPageState extends State<OrdemServicoFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _clienteSelecionadoId;
  String? _funcionarioSelecionadoId;
  String? _servicoSelecionadoId;
  bool _loadingGps = false;
  String? _enderecoClienteAtual;
  String? _cidadeClienteAtual;
  String? _estadoClienteAtual;

  TipoAtendimento _tipoSelecionado = TipoAtendimento.manutencao;
  OrderStatus _statusSelecionado = OrderStatus.aberto;
  bool _isExternal = false;

  final _basePriceController = TextEditingController();
  final _kmDistanceController = TextEditingController();
  final _observationsController = TextEditingController();

  // Campos específicos
  final _equipamentoController = TextEditingController();
  final _tipoDefeitoController = TextEditingController();
  final _modeloEquipamentoController = TextEditingController();
  final _metragemAmbienteController = TextEditingController();
  final _tensaoEletricaController = TextEditingController();
  final _equipamentoAvaliadoController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _solucaoRecomendadaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.osParaEditar != null) {
      final os = widget.osParaEditar!;
      _clienteSelecionadoId = os.clientId;
      _funcionarioSelecionadoId = os.employeeId;
      _tipoSelecionado = os.tipoAtendimento;
      _statusSelecionado = os.status;
      _isExternal = os.isExternal;

      _basePriceController.text = os.serviceBasePrice.toString();
      if (os.kmDistance > 0) {
        _kmDistanceController.text = os.kmDistance.toString();
      }

      _observationsController.text = os.observations ?? '';
      _equipamentoController.text = os.equipamento ?? '';
      _tipoDefeitoController.text = os.tipoDefeito ?? '';
      _modeloEquipamentoController.text = os.modeloEquipamento ?? '';
      _metragemAmbienteController.text = os.metragemAmbiente ?? '';
      _tensaoEletricaController.text = os.tensaoEletrica ?? '';
      _equipamentoAvaliadoController.text = os.equipamentoAvaliado ?? '';
      _diagnosticoController.text = os.diagnostico ?? '';
      _solucaoRecomendadaController.text = os.solucaoRecomendada ?? '';
      _statusSelecionado = os.status;
    }
  }

  @override
  void dispose() {
    _basePriceController.dispose();
    _kmDistanceController.dispose();
    _observationsController.dispose();
    _equipamentoController.dispose();
    _tipoDefeitoController.dispose();
    _modeloEquipamentoController.dispose();
    _metragemAmbienteController.dispose();
    _tensaoEletricaController.dispose();
    _equipamentoAvaliadoController.dispose();
    _diagnosticoController.dispose();
    _solucaoRecomendadaController.dispose();
    super.dispose();
  }

  Future<void> _calcularKmPeloGps() async {
    if (_clienteSelecionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente primeiro.')),
      );
      return;
    }

    setState(() => _loadingGps = true);

    try {
      final resultado = await context
          .read<OrdemServicoViewModel>()
          .calcularKmParaCliente(
            _enderecoClienteAtual!,
            _cidadeClienteAtual!,
            _estadoClienteAtual!,
          );

      setState(() {
        _kmDistanceController.text = resultado.distanciaKm.toStringAsFixed(2);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Rota calculada: ${resultado.distanciaKm.toStringAsFixed(2)} km — '
              'Taxa: R\$ ${resultado.taxa.toStringAsFixed(2)}',
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      setState(() => _loadingGps = false);
    }
  }

  InputDecoration _fieldDecoration(String label, {String? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.noiteArtica
          : AppColors.brancoPuro,
      labelStyle: const TextStyle(color: AppColors.azulProfundo, fontSize: 13),
      prefixStyle: const TextStyle(
        color: AppColors.azulGelo,
        fontWeight: FontWeight.w500,
      ),
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

  Widget _buildSectionCard({
    required String label,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.azulProfundo.withOpacity(0.4)
            : AppColors.brancoPuro,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.azulGelo.withOpacity(0.3),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
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
    final viewModelClientes = context.watch<ClientViewModel>();
    final viewModelFuncionarios = context.watch<FuncionarioViewModel>();
    final viewModelServicos = context.watch<ServiceViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isEditing = widget.osParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Ordem de Serviço' : 'Nova Ordem de Serviço',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
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
                  Text(
                    isEditing
                        ? 'Atualizar OS #${widget.osParaEditar!.id.substring(widget.osParaEditar!.id.length - 5)}'
                        : 'Abrir ordem de serviço',
                    style: const TextStyle(
                      color: AppColors.brancoPuro,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEditing
                        ? 'O técnico pode atualizar os dados abaixo'
                        : 'Preencha os dados para criar a OS',
                    style: const TextStyle(
                      color: AppColors.azulGelo,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildSectionCard(
              label: 'Dados da OS',
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _clienteSelecionadoId,
                  decoration: _fieldDecoration('cliente *'),
                  items: viewModelClientes.clients
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Por favor, selecione um cliente' : null,
                  onChanged: (val) {
                    setState(() {
                      _clienteSelecionadoId = val;
                      final cliente = viewModelClientes.clients.firstWhere(
                        (c) => c.id == val,
                      );
                      _enderecoClienteAtual = cliente.address;
                      _cidadeClienteAtual = cliente.city;
                      _estadoClienteAtual = cliente.state;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _funcionarioSelecionadoId,
                  decoration: _fieldDecoration('funcionário/técnico'),
                  items: viewModelFuncionarios.funcionarios
                      .map(
                        (f) =>
                            DropdownMenuItem(value: f.id, child: Text(f.name)),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Por favor, aloque um funcionário' : null,
                  onChanged: (val) =>
                      setState(() => _funcionarioSelecionadoId = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _servicoSelecionadoId,
                  decoration: _fieldDecoration('Serviço'),
                  items: viewModelServicos.services
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  validator: (value) => (value == null && !isEditing)
                      ? 'Por favor, selecione um serviço'
                      : null,
                  onChanged: (novoServicoId) {
                    if (novoServicoId != null) {
                      final servico = viewModelServicos.services.firstWhere(
                        (s) => s.id == novoServicoId,
                      );
                      setState(() {
                        _servicoSelecionadoId = novoServicoId;
                        _basePriceController.text = servico.basePrice
                            .toString();
                        _isExternal = servico.isExternal;
                        _tipoSelecionado = TipoAtendimento.values.firstWhere(
                          (t) => t.name == servico.tipoAtendimento.name,
                          orElse: () => TipoAtendimento.manutencao,
                        );
                      });
                    }
                  },
                ),
              ],
            ),

            _buildSectionCard(
              label: 'Informações básicas e Valores',
              children: [
                const Text(
                  'Tipo de atendimento',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.azulProfundo,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TipoAtendimento.values.map((tipo) {
                    final isSelected = _tipoSelecionado == tipo;
                    return ChoiceChip(
                      label: Text(_getTipoLabel(tipo)),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _tipoSelecionado = tipo),
                      selectedColor: AppColors.cianoFrio,
                      backgroundColor: isDark
                          ? AppColors.azulProfundo
                          : AppColors.brancoGelo,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.brancoPuro
                            : AppColors.azulProfundo,
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _basePriceController,
                  decoration: _fieldDecoration(
                    'Preço base cobrado nesta OS (Opcional)',
                    prefix: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.noiteArtica
                        : AppColors.brancoGelo,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.azulGelo.withOpacity(0.5),
                    ),
                  ),
                ),
                if (_isExternal) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _kmDistanceController,
                          decoration: _fieldDecoration(
                            'Distância até o cliente (km)',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) =>
                              (_isExternal && (value == null || value.isEmpty))
                              ? 'Insira a quilometragem'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _loadingGps
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              tooltip: 'Calcular pelo GPS',
                              icon: const Icon(
                                Icons.my_location,
                                color: AppColors.cianoFrio,
                              ),
                              onPressed: _calcularKmPeloGps,
                            ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Toque no ícone para calcular a rota real até o cliente',
                    style: TextStyle(fontSize: 11, color: AppColors.azulGelo),
                  ),
                ],
              ],
            ),

            // CAMPOS DINÂMICOS
            if (_tipoSelecionado == TipoAtendimento.manutencao)
              _buildSectionCard(
                label: 'Dados da Manutenção (Preenchido pelo Técnico)',
                children: [
                  TextFormField(
                    controller: _equipamentoController,
                    decoration: _fieldDecoration(
                      'Equipamento (Ex: Ar Condicionado Janela)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tipoDefeitoController,
                    decoration: _fieldDecoration('Tipo de Defeito Relatado'),
                  ),
                ],
              ),

            if (_tipoSelecionado == TipoAtendimento.instalacao)
              _buildSectionCard(
                label: 'Dados da Instalação (Preenchido pelo Técnico)',
                children: [
                  TextFormField(
                    controller: _modeloEquipamentoController,
                    decoration: _fieldDecoration('Modelo do Equipamento'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _metragemAmbienteController,
                    decoration: _fieldDecoration('Metragem do Ambiente (m²)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tensaoEletricaController,
                    decoration: _fieldDecoration(
                      'Tensão Elétrica (110v / 220v)',
                    ),
                  ),
                ],
              ),

            if (_tipoSelecionado == TipoAtendimento.visitaTecnica)
              _buildSectionCard(
                label: 'Laudo da Visita Técnica (Preenchido pelo Técnico)',
                children: [
                  TextFormField(
                    controller: _equipamentoAvaliadoController,
                    decoration: _fieldDecoration('Equipamento Avaliado'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _diagnosticoController,
                    decoration: _fieldDecoration('Diagnóstico Técnico'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _solucaoRecomendadaController,
                    decoration: _fieldDecoration('Solução Recomendada'),
                    maxLines: 2,
                  ),
                ],
              ),
            // OBSERVAÇÕES
            _buildSectionCard(
              label: 'Observações Gerais',
              children: [
                TextFormField(
                  controller: _observationsController,
                  decoration: _fieldDecoration('Notas adicionais'),
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.azulCeu, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.brancoPuro,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: Text(
                  isEditing ? 'Atualizar OS' : 'Salvar  OS',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final cleanPriceText = _basePriceController.text
                        .replaceAll('R\$ ', '')
                        .trim();
                    final basePrice = double.tryParse(cleanPriceText) ?? 0.0;
                    final kmDist = _isExternal
                        ? (double.tryParse(_kmDistanceController.text.trim()) ??
                              0.0)
                        : 0.0;

                    final idOrdem = isEditing
                        ? widget.osParaEditar!.id
                        : DateTime.now().millisecondsSinceEpoch.toString();

                    final osPronta = OrdemServico(
                      id: idOrdem,
                      clientId: _clienteSelecionadoId!,
                      employeeId: _funcionarioSelecionadoId!,
                      technicianId: _funcionarioSelecionadoId,
                      status: _statusSelecionado,
                      tipoAtendimento: _tipoSelecionado,
                      isExternal: _isExternal,
                      kmDistance: kmDist,
                      serviceBasePrice: basePrice,
                      kmFee: 0.0,
                      totalValue: 0.0,
                      observations: _observationsController.text.trim().isEmpty
                          ? null
                          : _observationsController.text.trim(),
                      equipamento: _equipamentoController.text.trim().isEmpty
                          ? null
                          : _equipamentoController.text.trim(),
                      tipoDefeito: _tipoDefeitoController.text.trim().isEmpty
                          ? null
                          : _tipoDefeitoController.text.trim(),
                      modeloEquipamento:
                          _modeloEquipamentoController.text.trim().isEmpty
                          ? null
                          : _modeloEquipamentoController.text.trim(),
                      metragemAmbiente:
                          _metragemAmbienteController.text.trim().isEmpty
                          ? null
                          : _metragemAmbienteController.text.trim(),
                      tensaoEletrica:
                          _tensaoEletricaController.text.trim().isEmpty
                          ? null
                          : _tensaoEletricaController.text.trim(),
                      equipamentoAvaliado:
                          _equipamentoAvaliadoController.text.trim().isEmpty
                          ? null
                          : _equipamentoAvaliadoController.text.trim(),
                      diagnostico: _diagnosticoController.text.trim().isEmpty
                          ? null
                          : _diagnosticoController.text.trim(),
                      solucaoRecomendada:
                          _solucaoRecomendadaController.text.trim().isEmpty
                          ? null
                          : _solucaoRecomendadaController.text.trim(),
                    );

                    await context.read<OrdemServicoViewModel>().salvarOrdem(
                      osPronta,
                      isPaid: isEditing ? widget.osParaEditar!.isPaid : false,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Ordem atualizada com sucesso!'
                                : 'Ordem de serviço cadastrada!',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                      Navigator.pop(context);
                    }
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

  String _getTipoLabel(TipoAtendimento tipo) {
    switch (tipo) {
      case TipoAtendimento.manutencao:
        return 'Manutenção';
      case TipoAtendimento.instalacao:
        return 'Instalação';
      case TipoAtendimento.visitaTecnica:
        return 'Visita técnica';
    }
  }
}
