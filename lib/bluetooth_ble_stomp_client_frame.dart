library bluetooth_ble_stomp_client;

import 'package:bluetooth_ble_stomp_client/bluetooth_ble_stomp_client_response_exception.dart';

/// A STOMP frame.
///
/// Follows the prescribed format of:
///
/// COMMAND
/// header:value
///
/// Body^@
class BluetoothBleStompClientFrame {
  /// Create a stomp frame given some frame String, header map, and body String.
  BluetoothBleStompClientFrame(
      {required this.command, required this.headers, this.body}) {
    result =
        constructFrameResult(receipt: command, headers: headers, body: body);
  }

  /// Create a STOMP frame from a string.
  BluetoothBleStompClientFrame.fromString({required String str}) {
    if (str.isEmpty || str == '') {
      throw BluetoothBleStompClientResponseException(
          message: 'Frame is empty');
    }
    List<String> lines = str.split('\n');

    if (lines.isEmpty) {
      throw BluetoothBleStompClientResponseException(
          message: 'Cannot split frame');
    }
    command = lines[0];

    int headerFrameBreak = 1;
    for (int i = 1; i < lines.length; i++) {
      if (lines[i].isEmpty || lines[i] == '\n') {
        headerFrameBreak = i;
        break;
      } else {
        List<String> headerResult = lines[i].split(':');
        if (headerResult.length != 2) {
          throw BluetoothBleStompClientResponseException(
              message: 'Header must have a corresponding value');
        }
        headers[headerResult[0]] = headerResult[1];
      }
    }

    StringBuffer buf = StringBuffer();
    for (int i = headerFrameBreak + 1; i < lines.length; i++) {
      buf.write(lines[i]);
    }
    body = buf.toString();

    result =
        constructFrameResult(receipt: command, headers: headers, body: body);
  }

  late final String command;
  Map<String, String> headers = {};
  late final String? body;
  String result = '';

  /// Construct thr result of a given receipt, headers and body.
  static String constructFrameResult(
      {required String receipt,
        required Map<String, String> headers,
        String? body}) {
    String result = '$receipt\n';

    for (String key in headers.keys) {
      result += ('$key:${headers[key]}\n');
    }
    result += '\n';

    if (body != null) {
      result += '$body\u0000';
    } else {
      result += '\u0000';
    }

    return result;
  }
}