import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Expense.dart';
import 'package:intl/intl.dart';

class ExpenseDB {
  static Database _database;

  Future<Database> get database async {
    if (_database == null) {
      _database = await initialize();
    }
    return _database;
  }

  initialize() async {
    var folder = await getApplicationDocumentsDirectory();
    var path = join(folder.path, "db.db");
    //await deleteDatabase(path);  // Не забыть убрать
    return openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE Expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, price REAL, date TEXT, name TEXT);");
          // await db.execute(
          //     "INSERT INTO Expenses (name, date, price) values (?, ?, ?);",
          //     ["iPhone", "21.03", 1000.0]);
          //print("Новая база");
        }
    );
  }

  Future getAllExpenses() async {
    var dbClient = await database;
    var result = await dbClient.rawQuery(
        'SELECT * FROM Expenses ORDER BY id DESC');

    return result.toList();
  }

  Future summary() async {
    var dbClient = await database;
    var datetime = DateFormat('.MM.yyyy').format(DateTime.now());
    var _price = await dbClient.rawQuery(
        "SELECT SUM(price) as price FROM Expenses WHERE date LIKE '%$datetime%';)");
    var _count = await dbClient.rawQuery(
        "SELECT COUNT(name) as count FROM Expenses;)");

    return [_price, _count];
  }

  Future saveExpense(name, price, date) async {
    var dbClient = await database;
    var result = await dbClient.rawQuery(
        'INSERT INTO Expenses (name, date, price) VALUES (?, ?, ?)',
        [name, date, price]);
    //print("Saved");
  }

  Future delete(int id) async {
    var dbClient = await database;
    return await dbClient.rawQuery('DELETE FROM Expenses WHERE id = $id');
  }

  Future updateExpense(name, price, id, date) async {
    var dbClient = await database;
    String _name = name.toString();
    double _price = double.tryParse(price);
    return await dbClient.rawQuery("UPDATE Expenses SET name = '$_name', price = $_price, date = '$date' WHERE id = $id;");
  }
}