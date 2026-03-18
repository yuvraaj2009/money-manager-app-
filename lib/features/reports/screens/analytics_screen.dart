import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/currency_formatter.dart';
import '../providers/report_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final breakdown = ref.watch(categoryBreakdownProvider);
    final trends = ref.watch(trendsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoryBreakdownProvider);
            ref.invalidate(trendsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text('Analytics', style: theme.textTheme.headlineMedium),
              ),
              const SizedBox(height: 24),

              // Total Insights + Efficiency Score
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL INSIGHTS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Spending Overview',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This month analysis',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 100,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '84',
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Score',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Spending Trends
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Spending Trends', style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: 12),
              trends.when(
                data: (data) => _SpendingTrendsChart(data: data, theme: theme),
                loading: () => _LoadingCard(height: 200),
                error: (_, __) => _ErrorCard(message: 'Failed to load trends'),
              ),
              const SizedBox(height: 24),

              // Category Breakdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Categories', style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: 12),
              breakdown.when(
                data: (data) => _CategoryBreakdownSection(data: data, theme: theme),
                loading: () => _LoadingCard(height: 300),
                error: (_, __) => _ErrorCard(message: 'Failed to load categories'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendingTrendsChart extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;

  const _SpendingTrendsChart({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    final months = data['months'] as List<dynamic>? ?? [];

    if (months.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(child: Text('No trend data yet', style: theme.textTheme.bodyMedium)),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < months.length; i++) {
      final m = months[i] as Map<String, dynamic>;
      final expenses = (m['total_expenses'] as num?)?.toDouble() ?? 0;
      spots.add(FlSpot(i.toDouble(), expenses));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBreakdownSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final ThemeData theme;

  const _CategoryBreakdownSection({required this.data, required this.theme});

  Color _parseColor(String hex) {
    final hexStr = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexStr', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final categories = data['categories'] as List<dynamic>? ?? [];

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          height: 200,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(child: Text('No category data yet', style: theme.textTheme.bodyMedium)),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sections: categories.take(6).map((cat) {
                    final c = cat as Map<String, dynamic>;
                    return PieChartSectionData(
                      color: _parseColor(c['color'] as String? ?? '#73739E'),
                      value: (c['percentage'] as num?)?.toDouble() ?? 0,
                      title: '${(c['percentage'] as num?)?.toStringAsFixed(0) ?? 0}%',
                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                      radius: 28,
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...categories.take(6).map((cat) {
              final c = cat as Map<String, dynamic>;
              final color = _parseColor(c['color'] as String? ?? '#73739E');
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c['name'] as String? ?? 'Unknown', style: theme.textTheme.bodyMedium),
                    ),
                    Text(
                      CurrencyFormatter.formatCompact((c['amount'] as num?)?.toDouble() ?? 0),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(c['percentage'] as num?)?.toStringAsFixed(0) ?? 0}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(child: Text(message)),
      ),
    );
  }
}
