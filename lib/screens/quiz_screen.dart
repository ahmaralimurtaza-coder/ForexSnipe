import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../models/quiz_models.dart';
import '../models/quiz_data.dart';

enum _View { levelSelect, quiz, results }

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  _View _view = _View.levelSelect;
  String _difficulty = 'Easy';
  List<QuizQuestion> _questions = [];
  int _index = 0;
  int? _selected;
  bool _answered = false;
  final List<QuizAttempt> _attempts = [];
  final _rng = Random();

  Color _diffColor(String d) {
    switch (d) {
      case 'Easy':   return AppColors.green;
      case 'Medium': return AppColors.gold;
      case 'Hard':   return AppColors.red;
      default:       return AppColors.cyan;
    }
  }

  List<QuizQuestion> _sourceFor(String d) {
    switch (d) {
      case 'Easy':   return QuizData.easy;
      case 'Medium': return QuizData.medium;
      case 'Hard':   return QuizData.hard;
      default:       return QuizData.easy;
    }
  }

  void _startQuiz(String difficulty) {
    final src = List<QuizQuestion>.from(_sourceFor(difficulty))..shuffle(_rng);
    setState(() {
      _difficulty = difficulty;
      _questions  = src;
      _index      = 0;
      _selected   = null;
      _answered   = false;
      _attempts.clear();
      _view = _View.quiz;
    });
  }

  void _selectOption(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      _attempts.add(QuizAttempt(question: _questions[_index], selectedIndex: i));
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      setState(() => _view = _View.results);
    } else {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    }
  }

  void _restartSameLevel() => _startQuiz(_difficulty);

  void _backToLevels() {
    setState(() {
      _view = _View.levelSelect;
      _questions = [];
      _attempts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case _View.levelSelect: return _buildLevelSelect(context);
      case _View.quiz:        return _buildQuiz(context);
      case _View.results:     return _buildResults(context);
    }
  }

  // ───────────────────────── LEVEL SELECT ─────────────────────────
  Widget _buildLevelSelect(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levels = [
      ('Easy', QuizData.easy.length, 'Candlestick basics & simple chart patterns',
          Icons.looks_one_outlined),
      ('Medium', QuizData.medium.length, 'Advanced candlesticks, chart patterns & indicators',
          Icons.looks_two_outlined),
      ('Hard', QuizData.hard.length, 'Prop firms, brokers, risk management, SMC & macro',
          Icons.local_fire_department_outlined),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionHeader(
              label: 'Test Your Knowledge', title: 'Trading', titleAccent: 'Quiz'),
          const SizedBox(height: 16),
          ...levels.map((l) {
            final (name, count, desc, icon) = l;
            final color = _diffColor(name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: () => _startQuiz(name),
                child: GlowCard(
                  glowColor: color,
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Icon(icon, color: color, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$count Questions',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        Text(desc, style: TextStyle(fontSize: 11.5,
                            color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                      ]),
                    ),
                    Icon(Icons.chevron_right, color: color),
                  ]),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          GlowCard(padding: const EdgeInsets.all(14), child: Row(children: [
            Icon(Icons.info_outline, size: 16,
                color: isDark ? AppColors.mutedDark : AppColors.mutedLight),
            const SizedBox(width: 8),
            Expanded(child: Text(
                'Questions are shuffled each attempt. Every level covers 100% unique questions with no repeats.',
                style: TextStyle(fontSize: 11,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight))),
          ])),
        ]),
      ),
    );
  }

  // ───────────────────────── QUIZ FLOW ─────────────────────────
  Widget _buildQuiz(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q      = _questions[_index];
    final color  = _diffColor(_difficulty);
    final progress = (_index + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _backToLevels),
        title: Text('$_difficulty Quiz', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Question ${_index + 1} of ${_questions.length}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(q.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress, minHeight: 6,
              backgroundColor: isDark ? AppColors.navyCard2 : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 20),
          GlowCard(
            glowColor: color,
            padding: const EdgeInsets.all(18),
            child: Text(q.question,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.4,
                    color: isDark ? AppColors.textDark : AppColors.textLight)),
          ),
          const SizedBox(height: 16),
          ...List.generate(q.options.length, (i) {
            final isCorrectAnswer = i == q.correctIndex;
            final isSelected      = i == _selected;
            Color bg, border;
            Color textColor = isDark ? AppColors.textDark : AppColors.textLight;

            if (!_answered) {
              bg = isDark ? AppColors.navyCard : AppColors.lightCard;
              border = isDark ? AppColors.navyBorder : AppColors.lightBorder;
            } else if (isCorrectAnswer) {
              bg = AppColors.green.withOpacity(0.15);
              border = AppColors.green;
              textColor = AppColors.green;
            } else if (isSelected && !isCorrectAnswer) {
              bg = AppColors.red.withOpacity(0.15);
              border = AppColors.red;
              textColor = AppColors.red;
            } else {
              bg = isDark ? AppColors.navyCard : AppColors.lightCard;
              border = isDark ? AppColors.navyBorder : AppColors.lightBorder;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _selectOption(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: isSelected || (_answered && isCorrectAnswer) ? 1.6 : 1),
                  ),
                  child: Row(children: [
                    Container(
                      width: 24, height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: textColor.withOpacity(0.6)),
                      ),
                      child: Text(String.fromCharCode(65 + i),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textColor)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(q.options[i],
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor))),
                    if (_answered && isCorrectAnswer)
                      const Icon(Icons.check_circle, color: AppColors.green, size: 18),
                    if (_answered && isSelected && !isCorrectAnswer)
                      const Icon(Icons.cancel, color: AppColors.red, size: 18),
                  ]),
                ),
              ),
            );
          }),
          if (_answered) ...[
            const SizedBox(height: 4),
            GlowCard(
              glowColor: color,
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(Icons.lightbulb_outline, size: 15, color: color),
                  const SizedBox(width: 6),
                  Text('EXPLANATION', style: TextStyle(fontSize: 10, letterSpacing: 1.5,
                      fontWeight: FontWeight.w700, color: color)),
                ]),
                const SizedBox(height: 8),
                Text(q.explanation, style: TextStyle(fontSize: 12.5, height: 1.4,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
              ]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_index + 1 >= _questions.length ? 'See Results' : 'Next Question',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  // ───────────────────────── RESULTS ─────────────────────────
  Widget _buildResults(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = _diffColor(_difficulty);
    final total  = _attempts.length;
    final correct = _attempts.where((a) => a.isCorrect).length;
    final pct = total > 0 ? (correct / total * 100) : 0.0;
    final wrong = _attempts.where((a) => !a.isCorrect).toList();

    String verdict;
    if (pct >= 90) verdict = 'Excellent! You know your stuff.';
    else if (pct >= 70) verdict = 'Solid performance, keep sharpening.';
    else if (pct >= 50) verdict = 'Decent start, review the misses below.';
    else verdict = 'Keep studying, review the misses below.';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _backToLevels),
        title: Text('$_difficulty Results', style: TextStyle(color: color, fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GlowCard(
            glowColor: color,
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Text('$correct / $total',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900,
                      color: color, fontFamily: 'monospace')),
              const SizedBox(height: 4),
              Text('${pct.toStringAsFixed(0)}% Correct',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
              const SizedBox(height: 10),
              Text(verdict, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.textLight)),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _restartSameLevel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry Level',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _backToLevels,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Change Level',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
              ),
            ),
          ]),
          if (wrong.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('REVIEW MISSED QUESTIONS (${wrong.length})',
                style: TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
            const SizedBox(height: 12),
            ...wrong.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlowCard(
                glowColor: AppColors.red,
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.question.question, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDark : AppColors.textLight)),
                  const SizedBox(height: 8),
                  if (a.selectedIndex != null)
                    Text('Your answer: ${a.question.options[a.selectedIndex!]}',
                        style: const TextStyle(fontSize: 12, color: AppColors.red, fontWeight: FontWeight.w600)),
                  Text('Correct answer: ${a.question.options[a.question.correctIndex]}',
                      style: const TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(a.question.explanation, style: TextStyle(fontSize: 11.5, height: 1.4,
                      color: isDark ? AppColors.mutedDark : AppColors.mutedLight)),
                ]),
              ),
            )),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
