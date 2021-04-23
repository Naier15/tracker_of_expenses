class Expense {
  int _id;
  String _date;
  String _name;
  double _price;

  int get id => _id;
  String get name => _name;
  double get price => _price;
  String get date => _date;

  Expense(this._id, this._date, this._name, this._price);

  Expense.fromMap(Map map) {
    this._id = map['id'];
    this._name = map['name'];
    this._date = map['date'];
    this._price = map['price'];
  }
}