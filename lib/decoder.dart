import 'dart:convert';

import 'package:des_bluetooth/state.dart';

class DicesDataDecoder {
  static void analyseData(List<int> d) {
    final String data = utf8.decode(d);
    //print("data : $data");

    if (data.startsWith("Dices=")) {
      sortStateFromDices(d); //DicesState
    } else if (data.startsWith("A-")) {
      sortState(d); // DicesState
    }
  }

  static void sortStateFromDices(List<int> info) {
    whiteDiceStateController.add(WhiteDiceState(info[6] - 48));
    blackDiceStateController.add(BlackDiceState(info[8] - 48));
    redDiceStateController.add(RedDiceState(info[10] - 48));
  }

  static void sortState(List<int> info) {
    final String data = utf8.decode(info);
    if (data.startsWith("A- Red")) {
      redDiceStateController.add(RedDiceState(info[19] - 48));
    } else if (data.startsWith("A-White")) {
      whiteDiceStateController.add(WhiteDiceState(info[19] - 48));
    } else if (data.startsWith("A-Black")) {
      blackDiceStateController.add(BlackDiceState(info[19] - 48));
    }
  }
}
