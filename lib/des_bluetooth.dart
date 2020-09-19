library des_bluetooth;

import 'dart:async';
import 'dart:convert';

import 'package:des_bluetooth/decoder.dart';
import 'package:des_bluetooth/state.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class Dices extends StatesRebuilder {
  Dices();
  static Dices get i => Injector.get<Dices>();

  void rebuild() {
    if (hasObservers) {
      rebuildStates();
    } else {
      log("no observers");
    }
  }

  void log(Object o) {
    //print(o.toString());
  }

  final Guid stateServiceGuid = Guid("6e400001-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid stateCharacteristicGuid =
      Guid("6e400003-b5a3-f393-e0a9-e50e24dcca9e");
  final Guid writeCharacteristicGuid =
      Guid("6e400002-b5a3-f393-e0a9-e50e24dcca9e");

  BluetoothService _stateService;
  BluetoothCharacteristic _stateCharacteristic;
  BluetoothCharacteristic _writeCharacteristic;

  BluetoothDevice _connectedDevice;
  BluetoothDevice get device {
    return _connectedDevice;
  }

  set device(BluetoothDevice d) {
    _connectedDevice = d;
    rebuild();
    return;
  }

  Future<BluetoothDevice> searchDices() async {
    final FlutterBlue flutterBlue = FlutterBlue.instance;
    log("SEARCHING.....");
    final listDevicesConnected = await FlutterBlue.instance.connectedDevices;
    final d = listDevicesConnected
        .firstWhere((res) => res.name == "MarcAntoine", orElse: () => null);
    if (d != null) {
      log("We already were connected to ${d.name} (${d.id.id})");
      await _initBluetooth(d);
      return d;
    }

    ScanResult res;
    for (var i = 0; i < 10; i++) {
      await flutterBlue.stopScan();
      log("searching...");
      res = await flutterBlue
          .scan(timeout: const Duration(seconds: 20))
          .firstWhere((scanResult) => scanResult.device.name == "MarcAntoine",
              orElse: () => null);

      if (res != null) {
        break;
      } else {
        log("No device found !");
      }
    }

    if (res == null) {
      throw Exception("Didnt find any device after 10 tries !!");
    }

    log("Found ${res.device.name} (${res.device.id.id})");
    await res.device.connect();
    await _initBluetooth(res.device);
    return res.device;
  }

  Future<void> _initBluetooth(BluetoothDevice d) async {
    log("initBluetooth");
    final List<BluetoothService> services = await d.discoverServices();

    _stateService = services.singleWhere((s) => s.uuid == stateServiceGuid);

    _stateCharacteristic = _stateService.characteristics
        .singleWhere((c) => c.uuid == stateCharacteristicGuid);

    _writeCharacteristic = _stateService.characteristics
        .singleWhere((w) => w.uuid == writeCharacteristicGuid);

    await _stateCharacteristic.setNotifyValue(true);
    log(DateTime.now());
    await Future.delayed(const Duration(milliseconds: 500));
    log(DateTime.now());
    device = d;

    _stateCharacteristic.value.listen((event) {
      log("got status");
      log(utf8.decode(event));
      DicesDataDecoder.analyseData(event);
    });

    d.state.listen((event) {
      log(event);
      if (event == BluetoothDeviceState.connected) {
        log("dices are connected");
      } else {
        log("+++++++++++++++++ CLEEAANNNN +++++++++++++++");
        clean();
        searchDices();
      }
    });
  }

  void clean() {
    device?.disconnect();
    device = null;
    _stateService = null;
    _stateCharacteristic = null;
    _writeCharacteristic = null;
  }

  Future<void> _write(String str, {int value}) async {
    log(str);
    final List<int> s = utf8.encode(str);
    final List<int> l = [];
    for (final i in s) {
      l.add(i);
    }
    if (value != null) {
      final List<int> v = utf8.encode(value.toString());
      for (final item in v) {
        l.add(item);
      }
    }
    l.add(10);
    log("Wrinting $l...");

    await _writeCharacteristic?.write(l);
    log(DateTime.now().millisecondsSinceEpoch);
    await Future.delayed(const Duration(milliseconds: 500));
    /* if (_stateCharacteristic != null) {
      final dataBrut = await _stateCharacteristic.read();
      log(dataBrut);
      final dynamic data = DicesDataDecoder.analyseData(dataBrut);
      log("data $data");
      return data as StateType;
    } else {
      return null;
    } */
    log("writing done");
    return;
  }

  Stream<DicesState> getStatus() {
    return CombineLatestStream.combine3(
        whiteDiceState, blackDiceState, redDiceState, (
      WhiteDiceState white,
      BlackDiceState black,
      RedDiceState red,
    ) {
      log("new dicesState");
      log(DicesState(white.data, black.data, red.data));
      return DicesState(white.data, black.data, red.data);
    }).asBroadcastStream();
  }

  Future<DicesState> getDicesState() async {
    await _write(WritingData.getDices);
    final DicesState response = await CombineLatestStream.combine3(
        whiteDiceState, blackDiceState, redDiceState, (
      WhiteDiceState white,
      BlackDiceState black,
      RedDiceState red,
    ) {
      return DicesState(white.data, black.data, red.data);
    }).asBroadcastStream().last;
    log("response : $response");
    if (response is DicesState) {
      log("response");
      return response;
    } else {
      return null;
    }
  }

  Future<void> vibreSuccess() async {
    await _write(WritingData.getVibration, value: WritingData.successVibrator);
  }
}

mixin WritingData {
  static String get getDices => "GET_DICES=";
  static String get getVibration => "VIB=";
  static int get successVibrator => 16;
}
