import 'package:flutter/material.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auction/data/models/auction_payment_config_model.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../shared/guards/admin_access_guard.dart';
import '../../../shared/widgets/admin_app_bar.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../data/sources/admin_bank_service.dart';

class AdminBankManagementPage extends StatefulWidget {
  const AdminBankManagementPage({super.key});

  @override
  State<AdminBankManagementPage> createState() =>
      _AdminBankManagementPageState();
}

class _AdminBankManagementPageState extends State<AdminBankManagementPage> {
  final AdminBankService _bankService = AdminBankService(ApiClient());
  bool _isLoading = true;
  String? _errorMessage;
  List<AuctionPaymentConfigModel> _banks = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ensureAdminAccess(context);
    });
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Khong tim thay access token';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final banks = await _bankService.getBanks(accessToken: accessToken);
      if (!mounted) return;
      setState(() {
        _banks = banks;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openBankForm([AuctionPaymentConfigModel? bank]) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BankFormSheet(
        bank: bank,
        onSave: _saveBank,
      ),
    );

    if (updated == true) {
      _loadBanks();
    }
  }

  Future<void> _saveBank({
    int? id,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String branchName,
    required String transferNotePrefix,
    required bool active,
  }) async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Khong tim thay access token');
    }

    await _bankService.saveBank(
      accessToken: accessToken,
      id: id,
      body: {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        'branchName': branchName,
        'transferNotePrefix': transferNotePrefix,
        'qrImageUrl': '',
        'active': active,
      },
    );
  }

  Future<void> _deleteBank(AuctionPaymentConfigModel bank) async {
    final id = bank.id;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa ngan hang'),
        content: Text('Ban co chac muon xoa ${bank.bankName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      _showError('Khong tim thay access token');
      return;
    }

    try {
      await _bankService.deleteBank(accessToken: accessToken, id: id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da xoa ngan hang')),
      );
      _loadBanks();
    } catch (error) {
      _showError(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          const AdminAppBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBanks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _buildErrorCard(_errorMessage!)
                    else if (_banks.isEmpty)
                      _buildEmptyCard()
                    else
                      ..._banks.map(_buildBankCard),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBankForm(),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Them ngan hang'),
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Quan ly ngan hang',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankCard(AuctionPaymentConfigModel bank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.bankName,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bank.accountNumber,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (bank.active)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(label: 'Chu TK', value: bank.accountHolderName),
          _InfoRow(label: 'Chi nhanh', value: bank.branchName ?? '---'),
          _InfoRow(
            label: 'Tien to CK',
            value: bank.transferNotePrefix ?? 'AUC',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openBankForm(bank),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Sua'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteBank(bank),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Xoa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFF991B1B))),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Chua co ngan hang nao.',
        style: TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BankFormSheet extends StatefulWidget {
  final AuctionPaymentConfigModel? bank;
  final Future<void> Function({
    int? id,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String branchName,
    required String transferNotePrefix,
    required bool active,
  }) onSave;

  const _BankFormSheet({
    required this.bank,
    required this.onSave,
  });

  @override
  State<_BankFormSheet> createState() => _BankFormSheetState();
}

class _BankFormSheetState extends State<_BankFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bankController;
  late final TextEditingController _accountController;
  late final TextEditingController _holderController;
  late final TextEditingController _branchController;
  late final TextEditingController _prefixController;
  late bool _active;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final bank = widget.bank;
    _bankController = TextEditingController(text: bank?.bankName ?? '');
    _accountController = TextEditingController(text: bank?.accountNumber ?? '');
    _holderController =
        TextEditingController(text: bank?.accountHolderName ?? '');
    _branchController = TextEditingController(text: bank?.branchName ?? '');
    _prefixController =
        TextEditingController(text: bank?.transferNotePrefix ?? 'AUC');
    _active = bank?.active ?? true;
  }

  @override
  void dispose() {
    _bankController.dispose();
    _accountController.dispose();
    _holderController.dispose();
    _branchController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSave(
        id: widget.bank?.id,
        bankName: _bankController.text.trim(),
        accountNumber: _accountController.text.trim(),
        accountHolderName: _holderController.text.trim(),
        branchName: _branchController.text.trim(),
        transferNotePrefix: _prefixController.text.trim(),
        active: _active,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bank == null ? 'Them ngan hang' : 'Sua ngan hang',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 18),
                _Input(controller: _bankController, label: 'Ma ngan hang'),
                _Input(controller: _accountController, label: 'So tai khoan'),
                _Input(controller: _holderController, label: 'Chu tai khoan'),
                _Input(controller: _branchController, label: 'Chi nhanh'),
                _Input(
                  controller: _prefixController,
                  label: 'Tien to noi dung CK',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  title: const Text('Dung lam tai khoan nhan tien active'),
                  onChanged: (value) => setState(() => _active = value),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Luu ngan hang'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _Input({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (label == 'Chi nhanh') return null;
          if (value == null || value.trim().isEmpty) {
            return 'Bat buoc';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF8FAFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '---' : value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
