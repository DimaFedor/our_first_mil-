import 'dart:convert';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/support_ticket.dart';

class SupportTicketService {
  static const String _queuedTicketsStorageKey = 'queued_support_tickets';

  final FirebaseFirestore? _firestore;
  final math.Random _random;

  SupportTicketService({FirebaseFirestore? firestore, math.Random? random})
    : _firestore = firestore,
      _random = random ?? math.Random();

  String createTicketId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = (_random.nextInt(9000) + 1000).toString();
    return 'SUP-$timestamp-$randomSuffix';
  }

  Future<SupportTicketSubmissionResult> submitTicket({
    required SupportTicket ticket,
    required bool useLocalMode,
  }) async {
    if (useLocalMode) {
      final queuedTicket = ticket.copyWith(
        status: 'queued_local',
        queuedLocally: true,
      );
      await _enqueueTicket(queuedTicket);
      return SupportTicketSubmissionResult(
        ticketId: queuedTicket.id,
        queuedLocally: true,
        message: 'Ticket was queued locally.',
      );
    }

    try {
      await (_firestore ?? FirebaseFirestore.instance)
          .collection('support_tickets')
          .doc(ticket.id)
          .set({
            ...ticket.toJson(),
            'status': 'open',
            'queuedLocally': false,
            'serverCreatedAt': FieldValue.serverTimestamp(),
          });

      return SupportTicketSubmissionResult(
        ticketId: ticket.id,
        queuedLocally: false,
        message: 'Ticket sent successfully.',
      );
    } on FirebaseException catch (error) {
      final queuedTicket = ticket.copyWith(
        status: 'queued_local',
        queuedLocally: true,
        lastError: error.code,
      );
      await _enqueueTicket(queuedTicket);

      return SupportTicketSubmissionResult(
        ticketId: queuedTicket.id,
        queuedLocally: true,
        message: 'Ticket was queued due to a network/backend issue.',
      );
    } on StateError catch (error) {
      final queuedTicket = ticket.copyWith(
        status: 'queued_local',
        queuedLocally: true,
        lastError: error.toString(),
      );
      await _enqueueTicket(queuedTicket);

      return SupportTicketSubmissionResult(
        ticketId: queuedTicket.id,
        queuedLocally: true,
        message: 'Ticket was queued because backend is unavailable.',
      );
    }
  }

  Future<List<SupportTicket>> getQueuedTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queuedTicketsStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <SupportTicket>[];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const <SupportTicket>[];
    }

    return decoded
        .whereType<Map>()
        .map((item) => SupportTicket.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<void> _enqueueTicket(SupportTicket ticket) async {
    final queued = await getQueuedTickets();
    final updated = <SupportTicket>[...queued, ticket];
    final encoded = jsonEncode(updated.map((item) => item.toJson()).toList());

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queuedTicketsStorageKey, encoded);
  }
}
