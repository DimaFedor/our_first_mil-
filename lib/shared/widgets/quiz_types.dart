import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Fill in the blank question widget
class FillInBlankQuestion extends StatefulWidget {
  final String questionText;
  final List<String> blanks; // The blanks to fill
  final List<String> options; // Available options to drag
  final Function(List<String> answers) onAnswered;
  final bool showResult;
  final bool isCorrect;

  const FillInBlankQuestion({
    super.key,
    required this.questionText,
    required this.blanks,
    required this.options,
    required this.onAnswered,
    this.showResult = false,
    this.isCorrect = false,
  });

  @override
  State<FillInBlankQuestion> createState() => _FillInBlankQuestionState();
}

class _FillInBlankQuestionState extends State<FillInBlankQuestion> {
  late List<String?> answers;
  late List<String> availableOptions;

  @override
  void initState() {
    super.initState();
    answers = List.filled(widget.blanks.length, null);
    availableOptions = List.from(widget.options);
  }

  void _fillBlank(int index, String option) {
    setState(() {
      // If blank already filled, return that option
      if (answers[index] != null) {
        availableOptions.add(answers[index]!);
      }
      answers[index] = option;
      availableOptions.remove(option);
    });
    
    if (!answers.contains(null)) {
      widget.onAnswered(answers.cast<String>());
    }
  }

  void _clearBlank(int index) {
    if (answers[index] != null) {
      setState(() {
        availableOptions.add(answers[index]!);
        answers[index] = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse question text and replace ___ with blank widgets
    final parts = widget.questionText.split('___');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question with blanks
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 0; i < parts.length; i++) ...[
              Text(
                parts[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  height: 2,
                ),
              ),
              if (i < answers.length)
                GestureDetector(
                  onTap: () => _clearBlank(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: answers[i] != null
                          ? (widget.showResult
                              ? (answers[i] == widget.blanks[i]
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444))
                              : const Color(0xFF0066FF))
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: answers[i] != null
                            ? Colors.transparent
                            : const Color(0xFF0066FF).withValues(alpha: 0.5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      answers[i] ?? '     ',
                      style: TextStyle(
                        color: answers[i] != null ? Colors.white : Colors.white38,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fadeIn().scale(),
            ],
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Available options
        const Text(
          'Drag to fill:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: availableOptions.map((option) {
            return Draggable<String>(
              data: option,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 16,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  // Find first empty blank
                  final emptyIndex = answers.indexOf(null);
                  if (emptyIndex != -1) {
                    _fillBlank(emptyIndex, option);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ).animate(delay: (availableOptions.indexOf(option) * 50).ms)
              .fadeIn()
              .slideX(begin: -0.1, end: 0);
          }).toList(),
        ),
      ],
    );
  }
}

// Code reorder question widget
class CodeReorderQuestion extends StatefulWidget {
  final String instruction;
  final List<String> codeLines;
  final List<int> correctOrder;
  final Function(List<int> order) onAnswered;
  final bool showResult;

  const CodeReorderQuestion({
    super.key,
    required this.instruction,
    required this.codeLines,
    required this.correctOrder,
    required this.onAnswered,
    this.showResult = false,
  });

  @override
  State<CodeReorderQuestion> createState() => _CodeReorderQuestionState();
}

class _CodeReorderQuestionState extends State<CodeReorderQuestion> {
  late List<int> currentOrder;

  @override
  void initState() {
    super.initState();
    // Shuffle the order initially
    currentOrder = List.generate(widget.codeLines.length, (i) => i);
    currentOrder.shuffle();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = currentOrder.removeAt(oldIndex);
      currentOrder.insert(newIndex, item);
    });
    widget.onAnswered(currentOrder);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.instruction,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Drag to reorder the code:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Reorderable list
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentOrder.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final originalIndex = currentOrder[index];
            final isCorrect = widget.showResult && 
                currentOrder[index] == widget.correctOrder[index];
            final isWrong = widget.showResult && 
                currentOrder[index] != widget.correctOrder[index];
            
            return Container(
              key: ValueKey(originalIndex),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isCorrect
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : isWrong
                        ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                        : const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect
                      ? const Color(0xFF10B981)
                      : isWrong
                          ? const Color(0xFFEF4444)
                          : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.codeLines[originalIndex],
                  style: const TextStyle(
                    color: Color(0xFF9CDCFE),
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
                trailing: Icon(
                  Icons.drag_handle,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            );
          },
        ),
        
        if (widget.showResult) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isCorrectOrder()
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _isCorrectOrder() ? Icons.check_circle : Icons.cancel,
                  color: _isCorrectOrder()
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isCorrectOrder()
                        ? 'Perfect! Code is in correct order.'
                        : 'Not quite right. Check the order.',
                    style: TextStyle(
                      color: _isCorrectOrder()
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _isCorrectOrder() {
    for (int i = 0; i < currentOrder.length; i++) {
      if (currentOrder[i] != widget.correctOrder[i]) return false;
    }
    return true;
  }
}

// True/False question widget
class TrueFalseQuestion extends StatefulWidget {
  final String statement;
  final bool correctAnswer;
  final String? explanation;
  final Function(bool answer) onAnswered;
  final bool? showResult;

  const TrueFalseQuestion({
    super.key,
    required this.statement,
    required this.correctAnswer,
    this.explanation,
    required this.onAnswered,
    this.showResult,
  });

  @override
  State<TrueFalseQuestion> createState() => _TrueFalseQuestionState();
}

class _TrueFalseQuestionState extends State<TrueFalseQuestion> {
  bool? selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.statement,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Row(
          children: [
            Expanded(
              child: _buildOption(true, 'TRUE', Icons.check),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOption(false, 'FALSE', Icons.close),
            ),
          ],
        ),
        
        if (widget.showResult == true && widget.explanation != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.explanation!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
        ],
      ],
    );
  }

  Widget _buildOption(bool value, String label, IconData icon) {
    final isSelected = selectedAnswer == value;
    final showResult = widget.showResult == true;
    final isCorrect = value == widget.correctAnswer;
    
    Color bgColor;
    Color borderColor;
    Color textColor;
    
    if (showResult && isSelected) {
      if (isCorrect) {
        bgColor = const Color(0xFF10B981).withValues(alpha: 0.2);
        borderColor = const Color(0xFF10B981);
        textColor = const Color(0xFF10B981);
      } else {
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.2);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFEF4444);
      }
    } else if (showResult && isCorrect) {
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.1);
      borderColor = const Color(0xFF10B981).withValues(alpha: 0.5);
      textColor = const Color(0xFF10B981);
    } else if (isSelected) {
      bgColor = const Color(0xFF0066FF).withValues(alpha: 0.2);
      borderColor = const Color(0xFF0066FF);
      textColor = const Color(0xFF0066FF);
    } else {
      bgColor = Colors.white.withValues(alpha: 0.05);
      borderColor = Colors.white.withValues(alpha: 0.2);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        if (widget.showResult != true) {
          setState(() => selectedAnswer = value);
          widget.onAnswered(value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
