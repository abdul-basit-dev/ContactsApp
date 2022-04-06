import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
//import 'contact_page.dart';

class SeeContactsButton extends StatefulWidget {
  const SeeContactsButton({Key? key}) : super(key: key);

  @override
  State<SeeContactsButton> createState() => _SeeContactsButtonState();
}

class _SeeContactsButtonState extends State<SeeContactsButton> {
  @override
  void initState() {
    super.initState();
    _checkForPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }

//Check contacts permission
  Future _checkForPermissions() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.pushReplacementNamed(context, "/contactPage");
      // Navigator.push(context,
      //     MaterialPageRoute(builder: (context) => const ContactsPage()));
    } else {
      //If permissions have been denied show standard cupertino alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Permissions error'),
          content: const Text('Please enable contacts access '
              'permission in system settings'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;

    if (permission != PermissionStatus.granted ||
        permission == PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.restricted;
    } else {
      return permission;
    }
  }
}
