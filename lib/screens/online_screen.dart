import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';
import '../services/prefs.dart';
import '../utils/game_logic.dart';
import '../utils/theme.dart';
import '../widgets/common.dart';
import 'game_screen.dart';

class OnlineScreen extends StatefulWidget {
  final bool quickMatch;
  const OnlineScreen({super.key, required this.quickMatch});

  @override
  State<OnlineScreen> createState() => _OnlineScreenState();
}

class _OnlineScreenState extends State<OnlineScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String? _roomId;
  bool _isHost = false;
  StreamSubscription? _sub;
  String _status = '';

  @override
  void initState() {
    super.initState();
    if (widget.quickMatch) _doQuickMatch();
  }

  Future<void> _doQuickMatch() async {
    setState(() { _loading = true; _status = 'گەڕان بەدوای بەرامبەر...'; });
    try {
      final secret = GameLogic.generateSecret();
      final roomId = await FirebaseService.quickMatch(Prefs.username, secret);
      _roomId = roomId;
      setState(() => _status = 'چاوەڕوانی بەرامبەر...');
      _listenRoom(roomId, secret);
    } catch (e) {
      setState(() { _loading = false; _status = 'هەڵە: $e'; });
    }
  }

  Future<void> _createRoom() async {
    setState(() { _loading = true; _status = 'ژووری دروست دەکرێت...'; });
    try {
      final secret = GameLogic.generateSecret();
      final roomId = await FirebaseService.createRoom(Prefs.username, secret);
      _roomId = roomId;
      _isHost = true;
      setState(() => _status = 'کۆدی ژوور: ${roomId.substring(0, 8).toUpperCase()}');
      _listenRoom(roomId, secret);
    } catch (e) {
      setState(() { _loading = false; _status = 'هەڵە: $e'; });
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() { _loading = true; _status = 'بەشداری دەکرێت...'; });
    try {
      final secret = GameLogic.generateSecret();
      await FirebaseService.joinRoom(code, Prefs.username, secret);
      _roomId = code;
      _isHost = false;
      _listenRoom(code, secret);
    } catch (e) {
      setState(() { _loading = false; _status = 'هەڵە: $e'; });
    }
  }

  void _listenRoom(String roomId, String secret) {
    _sub = FirebaseService.roomRef(roomId).onValue.listen((event) {
      if (!event.snapshot.exists) return;
      final data = event.snapshot.value as Map;
      final status = data['status'] as String?;
      if (status == 'playing' && mounted) {
        _sub?.cancel();
        final p2name = (data['player2'] as Map?)?['name'] as String? ?? 'بەرامبەر';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OnlineGameScreen(
              roomId: roomId,
              isHost: _isHost,
              mySecret: secret,
              opponentName: _isHost ? p2name : ((data['player1'] as Map?)?['name'] as String? ?? 'بەرامبەر'),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          widget.quickMatch ? 'یاری خێرا' : 'کۆدی نهێنی',
          style: const TextStyle(fontFamily: 'Orbitron', fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading) ...[
              const CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 20),
              Text(_status, style: const TextStyle(color: AppColors.textSecondary)),
              if (_roomId != null && _isHost) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _roomId!.substring(0, 8).toUpperCase()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('کۆدەکە کۆپی کرا')));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Text(
                      _roomId!.substring(0, 8).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('کۆدەکە بنێرە بۆ بەرامبەرەکەت',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ] else if (!widget.quickMatch) ...[
              PrimaryButton(
                label: 'ژووری دروست بکە',
                icon: Icons.add,
                color: AppColors.accent,
                onTap: _createRoom,
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('یان', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _codeCtrl,
                  style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 4, fontSize: 18),
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'کۆدی ژووری بنووسە',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(Icons.vpn_key_outlined, color: AppColors.cyan),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'بەشداری بکە',
                icon: Icons.login,
                color: AppColors.cyan,
                onTap: _joinRoom,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── ئەکرانی یاری ئۆنلاین ──
class OnlineGameScreen extends StatefulWidget {
  final String roomId;
  final bool isHost;
  final String mySecret;
  final String opponentName;

  const OnlineGameScreen({
    super.key,
    required this.roomId,
    required this.isHost,
    required this.mySecret,
    required this.opponentName,
  });

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final List<int> _input = [];
  final List<GuessEntry> _myGuesses = [];
  final List<GuessEntry> _oppGuesses = [];
  final Set<String> _processedMy = {};
  final Set<String> _processedOpp = {};
  bool _gameOver = false;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _listenRoom();
  }

  void _listenRoom() {
    _sub = FirebaseService.roomRef(widget.roomId).onValue.listen((event) {
      if (!event.snapshot.exists || !mounted) return;
      final data = event.snapshot.value as Map;
      final myKey = widget.isHost ? 'player1' : 'player2';
      final oppKey = widget.isHost ? 'player2' : 'player1';

      // ئەنجامی مەزندەکردنەکانی من
      final myGuesses = (data[myKey] as Map?)?['guesses'] as Map? ?? {};
      for (final e in myGuesses.entries) {
        final gId = e.key as String;
        final g = e.value as Map;
        final res = g['result'] as String? ?? '';
        if (res.isNotEmpty && !_processedMy.contains(gId)) {
          _processedMy.add(gId);
          final num = g['number'] as String? ?? '';
          setState(() => _myGuesses.insert(0, GuessEntry(num, res)));
          if (GameLogic.isWin(res)) _endGame(true);
        }
      }

      // مەزندەکردنەکانی بەرامبەر
      final mySecretStr = widget.mySecret;
      final oppGuesses = (data[oppKey] as Map?)?['guesses'] as Map? ?? {};
      for (final e in oppGuesses.entries) {
        final gId = e.key as String;
        final g = e.value as Map;
        final num = g['number'] as String? ?? '';
        final res = g['result'] as String? ?? '';
        if (num.isNotEmpty && res.isEmpty && !_processedOpp.contains('${gId}_eval')) {
          _processedOpp.add('${gId}_eval');
          final result = GameLogic.evaluate(mySecretStr, num);
          FirebaseService.writeResult(widget.roomId, widget.isHost, gId, result);
        }
        if (num.isNotEmpty && res.isNotEmpty && !_processedOpp.contains('${gId}_show')) {
          _processedOpp.add('${gId}_show');
          setState(() => _oppGuesses.insert(0, GuessEntry(num, res)));
          if (GameLogic.isWin(res)) _endGame(false);
        }
      }

      // تەواوبوونی یاری
      final status = data['status'] as String?;
      if (status == 'finished' && !_gameOver) {
        final winner = data['winner'] as String?;
        final iWon = (widget.isHost && winner == 'player1') ||
            (!widget.isHost && winner == 'player2');
        _endGame(iWon);
      }
    });
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

  Future<void> _submit() async {
    if (_input.length != 4 || _gameOver) return;
    final guess = _input.join();
    HapticFeedback.mediumImpact();
    setState(() => _input.clear());
    await FirebaseService.sendGuess(widget.roomId, widget.isHost, guess);
  }

  void _endGame(bool iWon) {
    if (_gameOver) return;
    setState(() => _gameOver = true);
    if (iWon) Prefs.addWin(); else Prefs.addLoss();
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
          style: TextStyle(color: iWon ? AppColors.success : AppColors.error, fontFamily: 'Orbitron'),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('دەرچوون', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    FirebaseService.leaveRoom(widget.roomId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          widget.opponentName,
          style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ئینپوت
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _input.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 54,
                  height: 60,
                  decoration: BoxDecoration(
                    color: filled ? AppColors.accent.withOpacity(0.15) : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: filled ? AppColors.accent : AppColors.border, width: filled ? 2 : 1),
                  ),
                  child: Center(
                    child: Text(
                      filled ? '${_input[i]}' : '',
                      style: const TextStyle(color: AppColors.accent, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Orbitron'),
                    ),
                  ),
                );
              }),
            ),
          ),

          // لیستەکان
          Expanded(
            child: Row(
              children: [
                _guessList('تۆ', _myGuesses, AppColors.accent),
                Container(width: 1, color: AppColors.border),
                _guessList(widget.opponentName, _oppGuesses, AppColors.error),
              ],
            ),
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
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: guesses.length,
              itemBuilder: (_, i) => GuessRow(number: guesses[i].number, result: guesses[i].result, index: i),
            ),
          ),
        ],
      ),
    );
  }
}
