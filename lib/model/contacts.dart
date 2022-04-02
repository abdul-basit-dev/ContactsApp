class MyContacts {
  String _name, _number;
  // Constructor for Creating new Class object
  MyContacts(this._name, this._number);

  // All the getters

  String get name => _name;
  String get number => _number;

  //All the setters
  set setName(String newName) {
    if (newName.length <= 255) {
      _name = newName;
    }
  }

  set setNumber(String newNumber) {
    _number = newNumber;
  }
}
