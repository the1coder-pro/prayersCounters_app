import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHelper {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _tapPlayer = AudioPlayer();

  static const String _completionUrl = "https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3";
  static const String _tapUrl = "https://www.soundjay.com/buttons/sounds/button-16.mp3";

  static Future<void> playCompletionSound() async {
    try {
      await _player.stop();
      // Try playing local asset, fallback to remote URL for web/CORS support
      try {
        await _player.play(AssetSource('completed.wav'));
      } catch (_) {
        await _player.play(UrlSource(_completionUrl));
      }
    } catch (e) {
      print("Error playing completion sound: $e");
    }
  }

  static Future<void> playTapSound() async {
    try {
      await _tapPlayer.stop();
      try {
        await _tapPlayer.play(AssetSource('select.wav'));
      } catch (_) {
        await _tapPlayer.play(UrlSource(_tapUrl));
      }
    } catch (e) {
      print("Error playing tap sound: $e");
    }
  }
}
