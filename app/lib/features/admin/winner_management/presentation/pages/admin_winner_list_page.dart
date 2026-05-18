import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/data/auth_session.dart';
import '../../../dashboard/presentation/pages/admin_dashboard_page.dart';
import '../../../shared/widgets/admin_bottom_navigation.dart';
import '../../data/services/admin_winner_service.dart';
import '../../domain/entities/winner_entity.dart';
import '../widgets/winner_filter_tabs.dart';
import '../widgets/winner_item_card.dart';
import '../widgets/winner_search_bar.dart';
import '../widgets/winner_stats_card.dart';

class AdminWinnerListPage extends StatefulWidget {
  const AdminWinnerListPage({super.key});

  @override
  State<AdminWinnerListPage> createState() => _AdminWinnerListPageState();
}

class _AdminWinnerListPageState extends State<AdminWinnerListPage> {
  final AdminWinnerService _winnerService = AdminWinnerService();
  int _selectedTab = 0;
  String _search = '';
  bool _loading = true;
  String? _error;
  List<WinnerEntity> _winners = const [];

  List<WinnerEntity> get _filteredWinners {
    final searched = _search.trim().toLowerCase();
    final source = searched.isEmpty
        ? _winners
        : _winners.where((winner) {
            return winner.productName.toLowerCase().contains(searched) ||
                winner.winnerName.toLowerCase().contains(searched);
          }).toList();

    if (_selectedTab == 0) return source;
    final status = _getStatusFromTab(_selectedTab);
    return source.where((winner) => winner.status == status).toList();
  }

  WinnerStatus? _getStatusFromTab(int index) {
    switch (index) {
      case 1:
        return WinnerStatus.won;
      case 2:
        return WinnerStatus.paid;
      case 3:
        return WinnerStatus.shipping;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWinners();
  }

  Future<void> _loadWinners() async {
    final accessToken = AuthSession.instance.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Ban can dang nhap admin';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final winners = await _winnerService.getWinners(accessToken: accessToken);
      if (!mounted) return;
      setState(() {
        _winners = winners;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final winners = _filteredWinners;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            WinnerSearchBar(
              onChanged: (value) => setState(() => _search = value),
            ),
            const SizedBox(height: 20),
            WinnerFilterTabs(
              selectedIndex: _selectedTab,
              onTabSelected: (index) => setState(() => _selectedTab = index),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadWinners,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(),
                    const SizedBox(height: 16),
                    if (_loading)
                      _buildLoadingState()
                    else if (_error != null)
                      _buildErrorState()
                    else if (winners.isEmpty)
                      _buildEmptyState()
                    else
                      ...winners.map(
                        (winner) => WinnerItemCard(winner: winner),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavigation(selectedIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
                return;
              }

              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
              );
            },
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          ),
          const Text(
            'Quan ly nguoi thang',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: WinnerStatsCard(
            label: 'DA THANG',
            value: _winners.length.toString(),
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: WinnerStatsCard(
            label: 'DANG XU LY',
            value: _winners
                .where((winner) => winner.status == WinnerStatus.won)
                .length
                .toString(),
            color: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Danh sach gan day',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF334155),
          ),
        ),
        TextButton(onPressed: _loadWinners, child: const Text('Tai lai')),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text('Khong co du lieu'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _error ?? 'Khong the tai du lieu',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadWinners,
              child: const Text('Thu lai'),
            ),
          ],
        ),
      ),
    );
  }
}
