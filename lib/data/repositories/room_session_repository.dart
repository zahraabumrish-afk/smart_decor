import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room_session.dart';

class RoomSessionRepository {
  RoomSessionRepository._();
  static final RoomSessionRepository I = RoomSessionRepository._();

  static const String _key = 'room_session_v1';

  Future<void> save(RoomSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(session.toJson()));
  }

  Future<RoomSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return RoomSession.fromJson(map);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}