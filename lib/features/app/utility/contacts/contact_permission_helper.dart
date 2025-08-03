import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactPermissionHelper {
  Future<List<Contact>> getContacts() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus != PermissionStatus.granted) {
      throw Exception('Contacts permission denied');
    }

    if (!await FlutterContacts.requestPermission()) {
      throw Exception('Contacts permission denied');
    }
    final contacts = await FlutterContacts.getContacts();
    return contacts;
  }

  Future<void> requestContactsPermission() async {
    var status = await Permission.contacts.status;
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      status = await Permission.contacts.request();
    }

    if (status.isGranted) {
      // Permission is granted. You can access contacts.
    } else if (status.isPermanentlyDenied) {
      // The user opted not to grant permission and selected to never ask again.
      // You can open app settings to let them grant permission from there.
      openAppSettings();
    }
  }
}
