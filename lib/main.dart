import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const TwoR2HApp());
}

class TwoR2HApp extends StatelessWidget {
  const TwoR2HApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2R2H',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== HOME SCREEN ====================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0F1E), Color(0xFF1A1A3E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // لۆگۆ
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4AA), Color(0xFF0099FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4AA).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '2R\n2H',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('یاری 2R2H', style: GoogleFonts.cairo(
                fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white,
              )),
              const SizedBox(height: 8),
              Text('ژمارەکانی بەرامبەرەکەت بدۆزەرەوە!',
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 20),
              // ڕێنمایی
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _rule('R', 'ژمارە و شوێن هەردوو ڕاستن'),
                    _rule('H', 'ژمارە ڕاستە بەڵام شوێن هەڵەیە'),
                    _rule('N', 'هیچ ژمارەیەک ڕاست نییە'),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _btn(context, '🎮  یاری لۆکاڵ', 'دوو کەس - یەک مۆبایل',
                      const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
                      () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const LocalGameScreen()))),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text('بەرهەمی کوردستان 🏔️',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white24)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rule(String tag, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00D4AA).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(tag, style: GoogleFonts.cairo(
              fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF00D4AA),
            )),
          ),
          const SizedBox(width: 10),
          Text(desc, style: GoogleFonts.cairo(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String label, String sub,
      Gradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5),
          )],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.cairo(
                  fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
                )),
                Text(sub, style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}

// ==================== GAME LOGIC ====================
class GameResult {
  final int right;
  final int wrongPlace;
  GameResult({required this.right, required this.wrongPlace});

  String toKurdish() {
    if (right == 4) return '🎉 بردیت!';
    if (right == 0 && wrongPlace == 0) return 'N';
    String r = '';
    if (right > 0) r += '${right}R';
    if (wrongPlace > 0) r += '${wrongPlace}H';
    return r;
  }

  bool get isWin => right == 4;
}

GameResult evaluate(String secret, String guess) {
  int r = 0, h = 0;
  for (int i = 0; i < 4; i++) {
    if (secret[i] == guess[i]) r++;
    else if (secret.contains(guess[i])) h++;
  }
  return GameResult(right: r, wrongPlace: h);
}

bool isValid(String g) {
  if (g.length != 4) return false;
  if (!RegExp(r'^\d{4}$').hasMatch(g)) return false;
  if (g[0] == '0') return false;
  return g.split('').toSet().length == 4;
}

// ==================== LOCAL GAME ====================
enum Phase { p1Secret, p2Secret, p1Guess, p2Guess, done }

class GuessEntry {
  final String guess;
  final GameResult result;
  GuessEntry(this.guess, this.result);
}

class LocalGameScreen extends StatefulWidget {
  const LocalGameScreen({super.key});
  @override
  State<LocalGameScreen> createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends State<LocalGameScreen> {
  Phase _phase = Phase.p1Secret;
  String _p1Secret = '', _p2Secret = '';
  final List<GuessEntry> _p1Guesses = [], _p2Guesses = [];
  final _ctrl = TextEditingController();
  String _err = '';
  int _winner = 0;

  void _submit() {
    final t = _ctrl.text.trim();
    setState(() => _err = '');
    switch (_phase) {
      case Phase.p1Secret:
        if (!isValid(t)) { setState(() => _err = 'ژمارەیەکی 4 ژیر بنووسە، دووبارە نەبێت، سفر نەبێتە سەرەوە'); return; }
        _p1Secret = t; _ctrl.clear();
        setState(() => _phase = Phase.p2Secret);
        _showPass('یاریزانی دووەم');
        break;
      case Phase.p2Secret:
        if (!isValid(t)) { setState(() => _err = 'ژمارەیەکی 4 ژیر بنووسە، دووبارە نەبێت، سفر نەبێتە سەرەوە'); return; }
        _p2Secret = t; _ctrl.clear();
        setState(() => _phase = Phase.p1Guess);
        _showPass('یاریزانی یەکەم');
        break;
      case Phase.p1Guess:
        if (!isValid(t)) { setState(() => _err = 'ژمارەیەکی 4 ژیر بنووسە'); return; }
        final r = evaluate(_p2Secret, t);
        setState(() { _p1Guesses.add(GuessEntry(t, r)); _ctrl.clear(); });
        if (r.isWin) { setState(() { _winner = 1; _phase = Phase.done; }); }
        else { setState(() => _phase = Phase.p2Guess); _showPass('یاریزانی دووەم'); }
        break;
      case Phase.p2Guess:
        if (!isValid(t)) { setState(() => _err = 'ژمارەیەکی 4 ژیر بنووسە'); return; }
        final r = evaluate(_p1Secret, t);
        setState(() { _p2Guesses.add(GuessEntry(t, r)); _ctrl.clear(); });
        if (r.isWin) { setState(() { _winner = 2; _phase = Phase.done; }); }
        else { setState(() => _phase = Phase.p1Guess); _showPass('یاریزانی یەکەم'); }
        break;
      case Phase.done: break;
    }
  }

  void _showPass(String next) {
    showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Text('مۆبایلەکە بدەرە بە $next\nچاوەکانت داخە!',
        style: GoogleFonts.cairo(color: Colors.white70, fontSize: 15),
        textAlign: TextAlign.center, textDirection: TextDirection.rtl),
      actions: [TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('ئامادەم ✅', style: GoogleFonts.cairo(
          color: const Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
      )],
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == Phase.done) return _winScreen();
    bool secret = _phase == Phase.p1Secret || _phase == Phase.p2Secret;
    String title = _phase == Phase.p1Secret || _phase == Phase.p1Guess
        ? 'یاریزانی یەکەم' : 'یاریزانی دووەم';
    List<GuessEntry> guesses = _phase == Phase.p1Guess || _phase == Phase.p1Secret
        ? _p1Guesses : _p2Guesses;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F1E), Color(0xFF1A1A3E)],
        )),
        child: SafeArea(child: Column(children: [
          // سەرەوە
          Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white)),
            const Spacer(),
            Text(title, style: GoogleFonts.cairo(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          ])),
          // لیستی تاقیکردنەوەکان
          Expanded(child: secret
            ? Center(child: Text('ژمارەی نهێنیت بنووسە 🔒',
                style: GoogleFonts.cairo(color: Colors.white38, fontSize: 16)))
            : guesses.isEmpty
              ? Center(child: Text('تاقی بکەرەوە! 🎯',
                  style: GoogleFonts.cairo(color: Colors.white38, fontSize: 16)))
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: guesses.length,
                  itemBuilder: (_, i) {
                    final g = guesses[guesses.length - 1 - i];
                    final isWin = g.result.isWin;
                    final Color c = isWin ? const Color(0xFF00D4AA)
                        : g.result.right > 0 ? const Color(0xFF0099FF)
                        : g.result.wrongPlace > 0 ? const Color(0xFFFF8E53)
                        : Colors.white24;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: c.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        Text('${guesses.length - i}',
                          style: GoogleFonts.cairo(color: Colors.white24, fontSize: 12)),
                        const SizedBox(width: 10),
                        ...g.guess.split('').map((d) => Container(
                          width: 34, height: 34,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text(d, style: GoogleFonts.cairo(
                            fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white))),
                        )),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: c.withOpacity(0.4)),
                          ),
                          child: Text(g.result.toKurdish(), style: GoogleFonts.cairo(
                            fontSize: 13, fontWeight: FontWeight.w700, color: c)),
                        ),
                      ]),
                    );
                  },
                )),
          // ئینپوت
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
            ),
            child: Column(children: [
              if (_err.isNotEmpty) Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_err, style: GoogleFonts.cairo(
                  color: const Color(0xFFFF6B6B), fontSize: 13),
                  textDirection: TextDirection.rtl),
              ),
              Row(children: [
                Expanded(child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: secret,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '• • • •',
                    hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 8),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF00D4AA), width: 2)),
                  ),
                  onSubmitted: (_) => _submit(),
                )),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4AA), Color(0xFF0099FF)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ]),
            ]),
          ),
        ])),
      ),
    );
  }

  Widget _winScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F1E), Color(0xFF1A1A3E)],
        )),
        child: SafeArea(child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text('یاریزانی $_winner بردی!', style: GoogleFonts.cairo(
              fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF00D4AA))),
            const SizedBox(height: 8),
            Text('ژمارەی نهێنی: ${_winner == 1 ? _p2Secret : _p1Secret}',
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.white60)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4AA), Color(0xFF0099FF)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('دووبارە یاری بکە', style: GoogleFonts.cairo(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ))),
      ),
    );
  }
}