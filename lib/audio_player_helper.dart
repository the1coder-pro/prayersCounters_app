import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playCompletionSound() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('completed.wav'));
    } catch (e) {
      // ignore
      print("Error playing sound: $e");
    }
  }
}
