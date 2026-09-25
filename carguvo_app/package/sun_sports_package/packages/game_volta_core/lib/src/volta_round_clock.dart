import 'volta_models.dart';
import 'volta_event.dart';

class VoltaRoundClock {
  const VoltaRoundClock._();

  static const int betLockSeconds = 2;

  static VoltaRoundPhase phaseOf(VoltaEvent? event, int nowSecond) {
    if (event == null || !event.hasStart) return VoltaRoundPhase.idle;
    if (nowSecond <= event.startSecond) return VoltaRoundPhase.betting;
    if (event.hasWinner) return VoltaRoundPhase.result;
    if (event.hasFinish && nowSecond > event.finishSecond) {
      return VoltaRoundPhase.settling;
    }
    return VoltaRoundPhase.playing;
  }

  static int secondsRemaining(VoltaEvent? event, int nowSecond) {
    if (event == null || !event.hasStart) return 0;
    final int remain = event.startSecond - nowSecond;
    return remain > 0 ? remain : 0;
  }

  static int countdownDigits(int secondsRemaining) =>
      secondsRemaining > 0 ? secondsRemaining - 1 : 0;

  static bool acceptsBets(VoltaRoundPhase phase, int secondsRemaining) =>
      phase == VoltaRoundPhase.betting && secondsRemaining > betLockSeconds;

  static VoltaWinner winnerOf(VoltaEvent? event) =>
      event == null ? VoltaWinner.unknown : VoltaWinner.fromCode(event.won);
}
