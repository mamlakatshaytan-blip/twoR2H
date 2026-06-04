import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final _db = FirebaseDatabase.instanceFor(
    app: FirebaseDatabase.instance.app,
    databaseURL: 'https://pls-wrya-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  static final _auth = FirebaseAuth.instance;
  static String? _uid;

  static Future<void> signIn() async {
    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      return;
    }
    final r = await _auth.signInAnonymously();
    _uid = r.user!.uid;
  }

  static String get uid => _uid ?? '';

  // ── ژووری دروست کردن ──
  static Future<String> createRoom(String username, String secret) async {
    await signIn();
    final ref = _db.child('rooms').push();
    await ref.set({
      'status': 'waiting',
      'player1': {'uid': uid, 'name': username, 'secret': secret},
      'createdAt': ServerValue.timestamp,
    });
    return ref.key!;
  }

  // ── بەشداری لە ژوور ──
  static Future<void> joinRoom(String roomId, String username, String secret) async {
    await signIn();
    await _db.child('rooms/$roomId').update({
      'player2': {'uid': uid, 'name': username, 'secret': secret},
      'status': 'playing',
    });
  }

  // ── چاوەڕوانی Fast Match ──
  static Future<String> quickMatch(String username, String secret) async {
    await signIn();
    // گەڕان بەدوای ژووری چاوەڕوان
    final snap = await _db.child('rooms')
        .orderByChild('status')
        .equalTo('waiting')
        .limitToFirst(1)
        .get();
    if (snap.exists) {
      final roomId = (snap.value as Map).keys.first as String;
      final data = (snap.value as Map)[roomId] as Map;
      if (data['player1']['uid'] != uid) {
        await joinRoom(roomId, username, secret);
        return roomId;
      }
    }
    // ژووری نوێ دروست بکە
    return await createRoom(username, secret);
  }

  // ── ئەنجامی مەزندەکردن نووسانەوە ──
  static Future<void> sendGuess(String roomId, bool isHost, String number) async {
    final myKey = isHost ? 'player1' : 'player2';
    await _db.child('rooms/$roomId/$myKey/guesses').push().set({
      'number': number,
      'result': '',
      'time': ServerValue.timestamp,
    });
  }

  static Future<void> writeResult(
      String roomId, bool isHost, String guessId, String result) async {
    final oppKey = isHost ? 'player2' : 'player1';
    await _db.child('rooms/$roomId/$oppKey/guesses/$guessId/result').set(result);
    if (result == '4R') {
      await _db.child('rooms/$roomId').update({
        'status': 'finished',
        'winner': isHost ? 'player2' : 'player1',
      });
    }
  }

  static DatabaseReference roomRef(String roomId) =>
      _db.child('rooms/$roomId');

  static Future<void> leaveRoom(String roomId) async {
    await _db.child('rooms/$roomId/status').set('abandoned');
  }
}
