import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  var status = await Permission.storage.request();
  print('Permission status: $status');
}
