import 'package:bored/model/RankType.dart';

class Rank {
  String _rank;

  Rank();

  String getRankFromLevel(int level) {
    if (level < 5) {
      _rank = RankType.newbie.toString().substring(9);
    } else if (level < 10) {
      _rank = RankType.beginner.toString().substring(9);
    } else if (level < 20) {
      _rank = RankType.intermediate.toString().substring(9);
    } else if (level < 50) {
      _rank = RankType.pro.toString().substring(9);
    } else {
      _rank = RankType.God.toString().substring(9);
    }
    return _rank;
  }
}
