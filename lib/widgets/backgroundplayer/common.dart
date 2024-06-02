import 'package:just_audio/just_audio.dart';
import 'package:titosapp/util/localStorage.dart';

class CustomAudioplayer {
  static AudioPlayer player = AudioPlayer();
  var localStorage = new LocalHiveStorage();

  static startPlayer(String url) async {
    try {
      var duration = await player.setUrl(url);
      await player.setLoopMode(LoopMode.all);
      print(duration);
    } catch (e) {
      print(e.toString());
    }
  }

  static setplayer(AudioPlayer pla) {
    player = pla;
  }

  static play() {
    player.play();
  }

  static stop() {
    player.stop();
  }
}
