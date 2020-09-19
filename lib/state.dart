import 'dart:async';

class DicesState extends StateType {
  final int _white;
  final int _black;
  final int _red;

  DicesState(this._white, this._black, this._red);
  @override
  String toString() {
    return "w: $_white, b: $_black, r:$_red";
  }

  @override
  DicesState get data => DicesState(_white, _black, _red);

  int get getWhite => _white ?? 1;
  int get getBlack => _black ?? 1;
  int get getRed => _red ?? 1;
}

class WhiteDiceState {
  final int data;
  WhiteDiceState(this.data);
}

class BlackDiceState {
  final int data;
  BlackDiceState(this.data);
}

class RedDiceState {
  final int data;
  RedDiceState(this.data);
}

StreamController<WhiteDiceState> whiteDiceStateController =
    StreamController.broadcast();
StreamController<BlackDiceState> blackDiceStateController =
    StreamController.broadcast();
StreamController<RedDiceState> redDiceStateController =
    StreamController.broadcast();

Stream<WhiteDiceState> get whiteDiceState => whiteDiceStateController.stream;
Stream<BlackDiceState> get blackDiceState => blackDiceStateController.stream;
Stream<RedDiceState> get redDiceState => redDiceStateController.stream;

abstract class StateType extends Type {
  dynamic get data;
}
