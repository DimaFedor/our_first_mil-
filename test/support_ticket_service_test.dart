import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/features/support/models/support_ticket.dart';
import 'package:untitled/features/support/services/support_ticket_service.dart';

void main() {
  group('SupportTicketService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('queues ticket locally in local mode', () async {
      final service = SupportTicketService();
      final ticket = SupportTicket(
        id: 'SUP-1',
        category: 'technical',
        subject: 'Challenge output mismatch',
        message: 'The coding challenge output does not match expected value.',
        userId: 'user-1',
        userEmail: 'user@example.com',
        userName: 'Tester',
        uiLanguageCode: 'uk',
        preferredLearningLanguage: 'python',
        createdAt: DateTime(2026, 1, 1),
      );

      final result = await service.submitTicket(
        ticket: ticket,
        useLocalMode: true,
      );

      expect(result.queuedLocally, isTrue);
      final queued = await service.getQueuedTickets();
      expect(queued.length, 1);
      expect(queued.first.subject, 'Challenge output mismatch');
      expect(queued.first.status, 'queued_local');
    });
  });
}
