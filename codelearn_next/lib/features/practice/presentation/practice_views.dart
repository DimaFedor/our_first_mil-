import 'package:flutter/material.dart';

import '../../../design_system/theme.dart';
import '../../../foundation/json.dart';

class CodePanel extends StatelessWidget {
  final String code;
  final String language;
  const CodePanel({super.key, required this.code, required this.language});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF090D19),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SelectableText(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.65,
          color: Color(0xFFDAE5FD),
        ),
      ),
    ),
  );
}

class SimulationView extends StatelessWidget {
  final JsonMap value;
  const SimulationView({super.key, required this.value});
  @override
  Widget build(BuildContext context) {
    final commits = jsonList(value['commits']);
    if (commits.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final raw in commits) ...[
            Row(
              children: [
                const Icon(Icons.commit_rounded, color: brandMint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${jsonMap(raw)['id']} · ${jsonMap(raw)['message']}',
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Text(
                jsonList(jsonMap(raw)['parents']).join(' ← '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
          const SizedBox(height: 8),
          for (final branch in jsonMap(value['branches']).entries)
            Text(
              '${branch.key} → ${branch.value}${branch.key == value['head'] ? '  ● HEAD' : ''}',
            ),
        ],
      );
    }
    return CodePanel(
      code: '${jsonString(value['pwd'])}\n${jsonString(value['fs_tree'])}',
      language: 'bash',
    );
  }
}
