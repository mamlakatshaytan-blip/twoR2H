import 'dart:math';

class GameLogic {
  static String generateSecret() {
    final digits = List.generate(9, (i) => i + 1)..shuffle(Random());
    return digits.take(4).join();
  }

  static String evaluate(String secret, String guess) {
    if (secret.length != 4 || guess.length != 4) return 'N';
    int r = 0, h = 0;
    for (int i = 0; i < 4; i++) {
      if (secret[i] == guess[i]) {
        r++;
      } else if (secret.contains(guess[i])) {
        h++;
      }
    }
    if (r == 0 && h == 0) return 'N';
    if (r > 0 && h > 0) return '${r}R${h}H';
    if (r > 0) return '${r}R';
    return '${h}H';
  }

  static bool isWin(String result) => result == '4R';
}

class GuessEntry {
  final String number;
  final String result;
  GuessEntry(this.number, this.result);
}
