import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/services/git_branching_simulator.dart';

void main() {
  test('initial simulator state has main at C0', () {
    final state = GitBranchingSimulator.initialState();

    expect(state.head, 'main');
    expect(state.branches['main'], 'C0');
    expect(state.commits.length, 1);
  });

  test('branch workflow creates diverging main and feature tips', () {
    final simulator = GitBranchingSimulator();
    final result = simulator.execute('''
git commit -m "base"
git branch feature
git checkout feature
git commit -m "feature work"
''');

    expect(result.hasError, isFalse);
    expect(result.state.head, 'feature');
    expect(result.state.branches['main'], 'C1');
    expect(result.state.branches['feature'], 'C2');
    expect(
      result.state.branches['main'],
      isNot(result.state.branches['feature']),
    );
  });

  test('merge command creates merge commit on current branch', () {
    final simulator = GitBranchingSimulator();
    final result = simulator.execute('''
git commit -m "base"
git branch feature
git checkout feature
git commit -m "feature work"
git checkout main
git merge feature
''');

    expect(result.hasError, isFalse);
    expect(result.state.head, 'main');
    expect(result.state.branches['main'], 'C3');
    final mergeCommit = result.state.commitById('C3');
    expect(mergeCommit, isNotNull);
    expect(mergeCommit!.parents.length, 2);
  });

  test('goal validation reports unmet requirements', () {
    final simulator = GitBranchingSimulator();
    final result = simulator.execute('git commit -m "base"');
    final goal = GitChallengeGoal.fromDsl('''
HEAD=feature
HAS_BRANCH=feature
MIN_COMMITS=3
''');

    final validation = simulator.validateGoal(state: result.state, goal: goal);

    expect(validation.isPassed, isFalse);
    expect(validation.failures, isNotEmpty);
  });
}
