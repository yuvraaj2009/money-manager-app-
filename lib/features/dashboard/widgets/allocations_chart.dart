import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/transaction_summary.dart';

class AllocationsChart extends StatelessWidget {
  final List<CategoryBreakdown> breakdown;

  const AllocationsChart({super.key, required this.breakdown});

  Color _parseColor(String hex) {
    final hexStr = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexStr', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (breakdown.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            'No spending data yet',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final topCategory = breakdown.isNotEmpty ? breakdown.first : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: breakdown.take(5).map((cat) {
                      return PieChartSectionData(
                        color: _parseColor(cat.categoryColor),
                        value: cat.percentage,
                        title: '',
                        radius: 24,
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 48,
                  ),
                ),
                if (topCategory != null)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'TOP CATEGORY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topCategory.categoryName,
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${topCategory.percentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: breakdown.take(4).map((cat) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _parseColor(cat.categoryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.categoryName,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
