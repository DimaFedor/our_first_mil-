import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Offline Status Provider
final offlineStatusProvider = StateNotifierProvider<OfflineStatusNotifier, bool>((ref) {
  return OfflineStatusNotifier();
});

class OfflineStatusNotifier extends StateNotifier<bool> {
  OfflineStatusNotifier() : super(false);
  
  void setOffline(bool isOffline) {
    state = isOffline;
  }
}

// Offline indicator widget
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(offlineStatusProvider);
    
    if (!isOffline) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            'Offline Mode',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
