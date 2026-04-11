import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/services/auth_challenge_service.dart';
import 'package:untitled/core/services/auth_flow_exception.dart';

void main() {
  group('AuthChallengeService', () {
    test('rejects invalid email when creating challenge', () {
      final service = AuthChallengeService();

      expect(
        () => service.issueChallenge(email: 'invalid-email'),
        throwsA(
          isA<AuthFlowException>().having(
            (e) => e.code,
            'code',
            'invalid-email',
          ),
        ),
      );
    });

    test('limits attempts and throws after repeated wrong answers', () {
      final service = AuthChallengeService();
      const email = 'tester@example.com';

      service.issueChallenge(email: email);

      expect(
        () => service.verifyAnswer(email: email, answer: 'wrong'),
        throwsA(
          isA<AuthFlowException>().having(
            (e) => e.code,
            'code',
            'challenge-wrong-answer',
          ),
        ),
      );

      expect(
        () => service.verifyAnswer(email: email, answer: 'wrong-again'),
        throwsA(
          isA<AuthFlowException>().having(
            (e) => e.code,
            'code',
            'challenge-wrong-answer',
          ),
        ),
      );

      expect(
        () => service.verifyAnswer(email: email, answer: 'wrong-third-time'),
        throwsA(
          isA<AuthFlowException>().having(
            (e) => e.code,
            'code',
            'challenge-attempts-exceeded',
          ),
        ),
      );
    });

    test('rate limits repeated challenge generation', () {
      final service = AuthChallengeService();
      const email = 'ratelimit@example.com';

      for (var i = 0; i < 5; i++) {
        service.issueChallenge(email: email);
        service.clearChallenge(email);
      }

      expect(
        () => service.issueChallenge(email: email),
        throwsA(
          isA<AuthFlowException>().having(
            (e) => e.code,
            'code',
            'challenge-rate-limited',
          ),
        ),
      );
    });
  });
}
