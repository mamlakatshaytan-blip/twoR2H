import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_logic.dart';
import '../utils/theme.dart';
import '../services/prefs.dart';
import '../widgets/common.dart';

enum GameMode { bot, local1v1, online }

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final String? roomId;
  final bool? isHost;
  final String? mySecret;
  final String? opponentName;

  const GameScreen({
    super.key,
    required this.mode,
    this.roomId,
    this.isHost,
    this.mySecret,
    this.opponentName,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String _secret;
  final List<int> _input = [];
  final List<GuessEntry> _playerGuesses = [];
  final List<GuessEntry> _botGuesses = [];
  bool _gameOver = false;
  bool _myTurn = true;
  String _p2Name = 'یاریزانی دووەم';

  @override
  void initState() {
    super.initState();
    _secret = widget.mySecret ?? GameLogic.generateSecret();
    if (widget.mode == GameMode.local1v1) {
      _p2Name = 'یاریزانی دووەم';
    } else if (widget.opponentName != null) {
      _p2Name = widget.opponentName!;
    }
  }

  void _pressDigit(int n) {
    if (_input.length >= 4 || _input.contains(n) || _gameOver) return;
    HapticFeedback.selectionClick();
    setState(() => _input.add(n));
  }

  void _delete() {
    if (_input.isEmpty) return;
    setState(() => _input.removeLast());
  }

  void _submit() {
    if (_input.length != 4 || _gameOver) return;
    final guess = _input.join();
    final result = GameLogic.evaluate(_secret, guess);
    HapticFeedback.mediumImpact();
    setState(() {
      _playerGuesses.insert(0, GuessEntry(guess, result));
      _input.clear();
    });
    if (GameLogic.isWin(result)) {
      _endGame(true);
      return;
    }
    if (widget.mode == GameMode.bot) {
      _botMove();
    }
  }

  void _botMove() {
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted || _gameOver) return;
      final botGuess = GameLogic.generateSecret();
      final result = GameLogic.evaluate(_secret, botGuess);
      setState(() => _botGuesses.insert(0, GuessEntry(botGuess, result)));
      if (GameLogic.isWin(result)) _endGame(false);
    });
  }

  void _endGame(bool iWon) {
    setState(() => _gameOver = true);
    if (iWon) {
      Prefs.addWin();
    } else {
      Prefs.addLoss();
    }
    Future.delayed(const Duration(milliseconds: 300), () => _showResult(iWon));
  }

  void _showResult(bool iWon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: iWon ? AppColors.success : AppColors.error),
        ),
        title: Text(
          iWon ? '🏆 بردیت!' : '💀 دەستت نەگەیشت',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: iWon ? AppColors.success : AppColors.error,
            fontFamily: 'Orbitron',
          ),
        ),
        content: Text(
          'ژمارەی نهێنی: $_secret',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 20, letterSpacing: 4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('دەرچوون', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _secret = GameLogic.generateSecret();
                _input.clear();
                _playerGuesses.clear();
                _botGuesses.clear();
                _gameOver = false;
              });
            },
            child: const Text('دووبارە', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showBot = widget.mode == GameMode.bot;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          showBot ? 'لەگەڵ بۆت' : '1 بەرامبەر 1',
          style: const TextStyle(fontFamily: 'Orbitron', fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // نمایشی ئینپوت
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _input.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 56,
                  height: 64,
                  decoration: BoxDecoration(
                    color: filled ? AppColors.accent.withOpacity(0.15) : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: filled ? AppColors.accent : AppColors.border,
                      width: filled ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      filled ? '${_input[i]}' : '',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // لیستی مەزندەکردنەکان
          Expanded(
            child: showBot
                ? Row(
                    children: [
                      _guessList('تۆ', _playerGuesses, AppColors.accent),
                      Container(width: 1, color: AppColors.border),
                      _guessList(_p2Name, _botGuesses, AppColors.error),
                    ],
                  )
                : _guessList('مەزندەکردنەکان', _playerGuesses, AppColors.accent),
          ),

          // کیبۆرد
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: NumberKeyboard(
              selected: _input,
              onTap: _pressDigit,
              onDelete: _delete,
              onSubmit: _submit,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guessList(String title, List<GuessEntry> guesses, Color color) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(title,
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: guesses.length,
              itemBuilder: (_, i) => GuessRow(
                number: guesses[i].number,
                result: guesses[i].result,
                index: i,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
