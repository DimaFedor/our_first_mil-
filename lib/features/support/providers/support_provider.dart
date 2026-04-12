import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/support_ticket_service.dart';

final supportTicketServiceProvider = Provider<SupportTicketService>((ref) {
  return SupportTicketService();
});
