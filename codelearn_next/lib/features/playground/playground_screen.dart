import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';

import '../../app/providers.dart';
import '../../design_system/components.dart';
import '../../foundation/json.dart';
import '../practice/data/practice_runner.dart';
import '../practice/presentation/code_editor.dart';

class PlaygroundScreen extends ConsumerStatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  ConsumerState<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends ConsumerState<PlaygroundScreen> {
  static const files = {'python': 'main.py', 'javascript': 'main.js'};
  final editors = {
    'python': CodeEditingController(
      language: 'python',
      text:
          'def greet(name):\n    return f"Привіт, {name}!"\n\nprint(greet("світе"))\n',
    ),
    'javascript': CodeEditingController(
      language: 'javascript',
      text:
          'function greet(name) {\n    return `Привіт, \${name}!`;\n}\n\nconsole.log(greet("світе"));\n',
    ),
  };
  final input = TextEditingController();
  final runner = PracticeRunner();
  final store = stringMapStoreFactory.store('playground');
  late final Database database;
  late final String account;
  Timer? saveTimer;
  Future<void> saveQueue = Future.value();
  String language = 'python';
  String output = '';
  String diagnostic = '';
  bool loading = true;
  bool loadFailed = false;
  bool saving = false;
  bool saveFailed = false;
  bool running = false;
  bool hasRun = false;
  int runId = 0;

  @override
  void initState() {
    super.initState();
    database = ref.read(repositoryProvider).database;
    account = ref.read(accountProvider);
    load();
  }

  Future<void> load() async {
    try {
      final data = await store.record(account).get(database);
      if (!mounted) return;
      if (data != null) {
        for (final entry in editors.entries) {
          if (data[entry.key] is String) {
            entry.value.text = data[entry.key] as String;
          }
        }
        input.text = jsonString(data['input']);
        final savedLanguage = jsonString(data['language']);
        if (files.containsKey(savedLanguage)) language = savedLanguage;
      }
    } catch (_) {
      loadFailed = true;
    }
    if (mounted) setState(() => loading = false);
  }

  void changed() {
    setState(() {
      saving = true;
      saveFailed = false;
    });
    saveTimer?.cancel();
    saveTimer = Timer(const Duration(milliseconds: 400), save);
  }

  Future<void> save() {
    final snapshot = <String, Object?>{
      for (final entry in editors.entries) entry.key: entry.value.text,
      'input': input.text,
      'language': language,
    };
    saveQueue = saveQueue.then((_) async {
      try {
        await store.record(account).put(database, snapshot);
        if (mounted) {
          setState(() {
            saving = saveTimer?.isActive ?? false;
            saveFailed = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            saving = false;
            saveFailed = true;
          });
        }
      }
    });
    return saveQueue;
  }

  Future<void> run() async {
    if (running || loading || loadFailed) return;
    final id = ++runId;
    setState(() {
      running = true;
      hasRun = true;
      output = '';
      diagnostic = '';
    });
    try {
      final result = await runner.run({
        'mode': 'playground',
        'code': editors[language]!.text,
        'input': input.text,
        'challenge': {'language': language},
      });
      if (!mounted || id != runId) return;
      setState(() {
        output = result.output;
        diagnostic = result.diagnostic;
        running = false;
      });
    } catch (_) {
      if (mounted && id == runId) {
        setState(() {
          diagnostic = 'workerUnavailable';
          running = false;
        });
      }
    }
  }

  void stop() {
    ++runId;
    runner.cancel();
    setState(() {
      running = false;
      diagnostic = 'cancelled';
    });
  }

  @override
  void dispose() {
    ++runId;
    runner.cancel();
    if (!loading && !loadFailed) {
      saveTimer?.cancel();
      unawaited(save());
    }
    for (final editor in editors.values) {
      editor.dispose();
    }
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (loading) return const Center(child: CircularProgressIndicator());
    if (loadFailed) return Center(child: Text(l.workspaceLoadError));
    final consoleText = running
        ? l.workspaceRunning
        : switch (diagnostic) {
            'timeout' => l.workspaceTimeout,
            'cancelled' => l.workspaceStopped,
            'workerUnavailable' => l.workspaceUnavailable,
            'unsupportedCode' => l.workspaceNoOutput,
            '' =>
              hasRun
                  ? (output.isEmpty ? l.workspaceNoOutput : output)
                  : l.workspaceReady,
            _ => diagnostic,
          };
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): run,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): run,
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final editor = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final file in files.entries)
                    ChoiceChip(
                      avatar: const Icon(Icons.code, size: 16),
                      label: Text(file.value),
                      selected: language == file.key,
                      onSelected: running
                          ? null
                          : (_) {
                              setState(() {
                                language = file.key;
                                output = '';
                                diagnostic = '';
                                hasRun = false;
                              });
                              changed();
                            },
                    ),
                  FilledButton.icon(
                    onPressed: running ? stop : run,
                    icon: Icon(
                      running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    ),
                    label: Text(running ? l.workspaceStop : l.workspaceRun),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D19),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: LearningCodeEditor(
                  key: ValueKey(language),
                  controller: editors[language]!,
                  onChanged: (_) => changed(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.workspaceShortcut,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
          final console = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: input,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) => changed(),
                decoration: InputDecoration(
                  labelText: l.workspaceInput,
                  helperText: l.workspaceInputHint,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.workspaceConsole,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: l.workspaceClear,
                    onPressed: running
                        ? null
                        : () => setState(() {
                            output = '';
                            diagnostic = '';
                            hasRun = false;
                          }),
                    icon: const Icon(Icons.clear_all),
                  ),
                ],
              ),
              Container(
                constraints: const BoxConstraints(minHeight: 220),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF090D19),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(
                  consoleText,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    height: 1.6,
                    color: diagnostic.isNotEmpty
                        ? const Color(0xFFFFB4AB)
                        : const Color(0xFFDCF2EC),
                  ),
                ),
              ),
            ],
          );
          return SingleChildScrollView(
            padding: EdgeInsets.all(wide ? 28 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.codeWorkspace,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(l.codeWorkspaceBody),
                const SizedBox(height: 8),
                Text(
                  saveFailed
                      ? l.workspaceSaveError
                      : saving
                      ? l.workspaceSaving
                      : l.workspaceSaved,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: editor),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: console),
                    ],
                  )
                else ...[
                  editor,
                  const SizedBox(height: 20),
                  console,
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
