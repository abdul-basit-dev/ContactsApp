// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:http/http.dart' as http;
import '../model/contacts.dart';
import 'package:flutter/cupertino.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // Get all contacts on device
  List<Contact>? _contacts;
  final List<MyContacts> _selectedItems = [];

  late List<bool> _isChecked;
  String msg = "";
  String webUrl = "https://3toprealtors.com/addContacts.php";
  bool? error, success;
  bool sending = true;

  var title, number;

  @override
  void initState() {
    super.initState();
    getContacts();
    error = false;
    success = false;
  }

  Future<void> getContacts() async {
    //We already have permissions for contact when we get to this page, so we
    // are now just retrieving it
    final List<Contact>? contacts = await ContactsService.getContacts(
        withThumbnails: false, iOSLocalizedLabels: true);

    setState(() {
      _contacts = contacts;

      _isChecked =
          List<bool>.filled(_contacts?.length ?? _contacts!.length, false);
    });
  }

  // This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, String phone, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(MyContacts(itemValue, phone));
        // debugPrint("selected " + itemValue + phone);
      } else {
        _selectedItems.remove(MyContacts(itemValue, phone));
        // debugPrint("Not selected");
      }
    });
  }

  Future<void> sendData(String name, String number) async {
    var res = await http.post(Uri.parse(webUrl), body: {
      "name": name,
      "user_number": number,
    }); //sending post request with header data

    if (res.statusCode == 200) {
      if (res.body.toString().contains("0")) {
        setState(() {
          sending = false;
          error = true;
          //refresh the UI when error is recieved from server
        });
        // _showAlertDialog("OOPPs", "Uploading Failed.");
      } else if (res.body.toString().contains("1")) {
        //after write success, make fields empty
        setState(() {
          success = true;
          _isChecked =
              List<bool>.filled(_contacts?.length ?? _contacts!.length, false);
          _selectedItems.add(MyContacts("", ""));
          _selectedItems.clear();
        });
      }
    } else {
      //there is error
      setState(() {
        error = true;
        sending = false;
        msg = "Error during sendign data.";
        //mark error and refresh UI with setState
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            final List<MyContacts> _items = _selectedItems;
            for (var i in _items) {
              title = i.name;
              number = i.number;
              debugPrint("Ready :" + title + number);
              if (sending) {
                CircularProgressIndicator;
                sendData(title, number);
              }
            }

            if (sending && _selectedItems.isNotEmpty) {
              _showAlertDialog("Operation Successfull", "Contacts added!.");
            } else {
              _showAlertDialog(
                  "Operation Failed", "Contacts failed tp upload!.");
            }
          },
          child: Ink(
            color: Colors.blue,
            height: kToolbarHeight,
            padding: const EdgeInsets.only(top: 16.0),
            child: const Text("Upload"),
          ),
        ),
        centerTitle: false,
        actions: [
          InkWell(
            onTap: () {
              setState(() {
                for (var i = 0; i < _isChecked.length; i++) {
                  _isChecked[i] = true;
                }
                List<Contact> contact = _contacts!;

                for (var item in contact) {
                  title = item.displayName;
                  final List<Item> _items = item.phones!;
                  for (var i in _items) {
                    number = i.value ?? "";
                    _selectedItems.add(MyContacts(title!, number));
                    debugPrint("added:" + title + number);
                  }
                }
              });
            },
            child: const Padding(
              padding: EdgeInsets.fromLTRB(0.0, 16.0, 24.0, 16.0),
              child: Text(
                'SELECT ALL',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          )
        ],
      ),
      body: _contacts != null
          //Build a list view of all contacts, displaying their avatar and
          // display name
          ? ListView.builder(
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact? contact = _contacts!.elementAt(index);

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 18),
                  leading:
                      (contact.avatar != null && contact.avatar!.isNotEmpty)
                          ? CircleAvatar(
                              backgroundImage: MemoryImage(contact.avatar!),
                            )
                          : CircleAvatar(
                              child: Text(contact.initials()),
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                  title: Text(contact.displayName ?? ''),
                  trailing: Checkbox(
                    checkColor: Colors.white,
                    value: _isChecked[index],
                    onChanged: (val) {
                      setState(
                        () {
                          _isChecked[index] = val!;
                          final List<Item> _items = contact.phones!;
                          var disNames = _items.toSet().toList();
                          for (var i in disNames) {
                            var phones = i.value ?? "";
                            _itemChange(
                                contact.displayName.toString(), phones, val);
                          }
                        },
                      );
                    },
                  ),
                  //subtitle: ItemsTile("Phones", contact.phones!),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
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

class ItemsTile extends StatelessWidget {
  const ItemsTile(this._title, this._items, {Key? key}) : super(key: key);

  final List<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(title: Text(_title)),
        Column(
          children: [
            for (var i in _items)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ListTile(
                  title: Text(i.label ?? ""),
                  trailing: Text(i.value ?? ""),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
