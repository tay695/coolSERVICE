import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';
import 'package:coolservice/freatures/servico/presentation/view_model/Service_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdemServicoFormPage extends StatefulWidget {
  const OrdemServicoFormPage({super.key});

  @override
  State<OrdemServicoFormPage> createState() => _OrdemServicoFormPageState();
}

class _OrdemServicoFormPageState extends State<OrdemServicoFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _clienteSelecionadoId;
  String? _funcionarioSelecionadoId;
  String? _servicoSelecionadoId;

  TipoAtendimento _tipoSelecionado = TipoAtendimento.manutencao;
  final OrderStatus _statusSelecionado = OrderStatus.open;
  bool _isExternal = false;

  // Campos base
  final _basePriceController = TextEditingController();
  final _kmDistanceController = TextEditingController();
  final _observationsController = TextEditingController();

  // Campos específicos de Manutenção
  final _equipamentoController = TextEditingController();
  final _tipoDefeitoController = TextEditingController();

  // Campos específicos de Instalação
  final _modeloEquipamentoController = TextEditingController();
  final _metragemAmbienteController = TextEditingController();
  final _tensaoEletricaController = TextEditingController();

  // Campos específicos de Visita Técnica
  final _equipamentoAvaliadoController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _solucaoRecomendadaController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(title: const Text('Nova Ordem de Serviço')),
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
                  const Text(
                    'Abrir ordem de serviço',
                    style: TextStyle(
                      color: AppColors.brancoPuro,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Preencha os dados para criar a OS',
                    style: TextStyle(color: AppColors.azulGelo, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CARD 1: VÍNCULOS
            _buildSectionCard(
              label: 'Vínculos',
              children: [
                DropdownButtonFormField<String>(
                  value: _clienteSelecionadoId,
                  decoration: _fieldDecoration('Selecione o cliente'),
                  items: viewModelClientes.clients
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Por favor, selecione um cliente' : null,
                  onChanged: (val) =>
                      setState(() => _clienteSelecionadoId = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _funcionarioSelecionadoId,
                  decoration: _fieldDecoration('Alocar funcionário/técnico'),
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
                  value: _servicoSelecionadoId,
                  decoration: _fieldDecoration(
                    'Sugestão de serviço do catálogo (Opcional)',
                  ),
                  items: viewModelServicos.services
                      .map(
                        (s) =>
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (novoServicoId) {
                    if (novoServicoId != null) {
                      final servico = viewModelServicos.services.firstWhere(
                        (s) => s.id == novoServicoId,
                      );
                      setState(() {
                        _servicoSelecionadoId = novoServicoId;
                        _basePriceController.text = servico.basePrice
                            .toString();
                        _tipoSelecionado =
                            servico.tipoAtendimento as TipoAtendimento;
                        _isExternal = servico.isExternal;
                      });
                    }
                  },
                ),
              ],
            ),

            // CARD 2: VALORES E LOGÍSTICA
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
                    'Preço base cobrado nesta OS',
                    prefix: 'R\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Insira o valor cobrado'
                      : null,
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
                  child: SwitchListTile(
                    title: const Text(
                      'Serviço externo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Cobrar deslocamento por KM?',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: _isExternal,
                    activeColor: AppColors.cianoFrio,
                    onChanged: (valor) => setState(() => _isExternal = valor),
                  ),
                ),
                if (_isExternal) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _kmDistanceController,
                    decoration: _fieldDecoration(
                      'Distância total ida/volta (km)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        (_isExternal && (value == null || value.isEmpty))
                        ? 'Insira a quilometragem'
                        : null,
                  ),
                ],
              ],
            ),

            // CAMPOS DINÂMICOS CONFORME O TIPO DE ATENDIMENTO
            if (_tipoSelecionado == TipoAtendimento.manutencao)
              _buildSectionCard(
                label: 'Dados da Manutenção',
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
                label: 'Dados da Instalação',
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
                label: 'Laudo da Visita Técnica',
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

            // OBSERVAÇÕES GERAIS
            _buildSectionCard(
              label: 'Observações Gerais',
              children: [
                TextFormField(
                  controller: _observationsController,
                  decoration: _fieldDecoration(
                    'Notas adicionais sobre a ordem de serviço',
                  ),
                  maxLines: 3,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Botão Cancelar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.azulCeu, fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),

            // Botão Principal de Salvamento
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
                label: const Text(
                  'Salvar ordem de serviço',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Sanitização de strings para double com segurança
                    final cleanPriceText = _basePriceController.text
                        .replaceAll('R\$ ', '')
                        .trim();
                    final basePrice = double.tryParse(cleanPriceText) ?? 0.0;

                    final kmDist = _isExternal
                        ? (double.tryParse(_kmDistanceController.text.trim()) ??
                              0.0)
                        : 0.0;

                    final novaOS = OrdemServico(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      clientId: _clienteSelecionadoId!,
                      employeeId: _funcionarioSelecionadoId!,
                      technicianId: _funcionarioSelecionadoId,
                      status: _statusSelecionado,
                      tipoAtendimento: _tipoSelecionado,
                      isExternal: _isExternal,
                      kmDistance: kmDist,
                      serviceBasePrice: basePrice,
                      kmFee: 0.0, // Tratado dinamicamente pela ViewModel
                      totalValue: 0.0, // Tratado dinamicamente pela ViewModel
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

                    // Executa a persistência e regras matemáticas de KM pela ViewModel
                    await context.read<OrdemServicoViewModel>().salvarOrdem(
                      novaOS,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ordem de serviço cadastrada com sucesso!',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                      Navigator.pop(
                        context,
                      ); // Retorna para a tela de listagem atualizada
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
