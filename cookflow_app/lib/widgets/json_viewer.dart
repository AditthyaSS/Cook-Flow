import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme.dart';

class JsonViewer extends StatelessWidget {
  final Map<String, dynamic> data;

  const JsonViewer({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(data);

    return Card(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.code,
                  color: AppTheme.accentGreen,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  'Raw JSON Response',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentGreen,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.textDark.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.textLight.withOpacity(0.3),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  prettyJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppTheme.textDark,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
