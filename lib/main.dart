import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:homework/UpdateExpenseDialog.dart';
import 'ExpenseDB.dart';
import 'Expense.dart';


void main() {
  runApp(
      MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: MyApp()
      )
  );
}

class MyAppState extends State<MyApp> {
  List items = [];
  ExpenseDB db = new ExpenseDB();
  double _price;
  int _count;
  Expense n;

  @override
  void initState() {
    super.initState();

    db.getAllExpenses().then((values) {
      setState(() {
        values.forEach((value) {
          items.add(Expense.fromMap(value));
        });
      });
    });
    updating();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(title: Text("Трекер покупок"),
          centerTitle: true,
          backgroundColor: Color.fromARGB(200, 60, 200, 250)),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children:
          [Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(100, 80, 190, 220))),
            child:
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: TextDirection.ltr,
                children:
                [Expanded(
                    flex: 30,
                    child:
                    Container(
                        alignment: Alignment.center,
                        height: 80,
                        child: Text("Покупки\nза месяц:",
                            textDirection: TextDirection.ltr,
                            style: TextStyle(fontSize: 21),
                            overflow: TextOverflow.clip)
                    )
                ),
                  Spacer(flex: 1,),
                  Expanded(
                      flex: 40,
                      child:
                      Container(
                          height: 80,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                              [Text("Количество",
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.clip),
                                Text(_count.toString(),
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(fontSize: 24))
                              ])
                      )
                  ),
                  Spacer(flex: 1,),
                  Expanded(
                      flex: 40,
                      child:
                      Container(
                          alignment: Alignment.center,
                          height: 80,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                              [Text("Рублей",
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.clip),
                                Text(_price.toString(),
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(fontSize: 24))
                              ])
                      )
                  )
                ]
            ),
          ),
            Container(
                height: 600,
                width: 400,
                child:
                ListView.separated(
                    padding: EdgeInsets.all(20),
                    physics: BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(thickness: 2, color: Colors.cyanAccent),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          key: Key("${items[index].id}"),
                          title: Text(
                              "${items[index].name}\n${items[index].price} руб.",
                              style: TextStyle(fontSize: 22)),
                          leading: Icon(Icons.monetization_on_outlined, size: 30),
                          trailing: Wrap(spacing: -20,
                              children: [
                                TextButton(
                                    child: Icon(Icons.create, size: 25),
                                    style: TextButton.styleFrom(
                                              primary: Colors.white,
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(10),
                                    ),
                                    onPressed: () => navigateToExpense(context, items[index])),
                                TextButton(
                                      child: Icon(Icons.delete, size: 25),
                                      style: TextButton.styleFrom(
                                              primary: Colors.white,
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(10),
                                              ),
                                      onPressed: () => showDialog<void>(context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Вы точно хотите удалить эту запись из списка?'),
                                            titleTextStyle: TextStyle(fontSize: 27),
                                            content: const Text('Действие будет невозможно отменить'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Подтвердить', style: TextStyle(fontSize: 21)),
                                                onPressed: () {
                                                  deleteItem(context, items[index], index);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Отменить', style: TextStyle(fontSize: 21)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ))
                              ]),
                          subtitle: Text("${items[index].date.toString()}"),
                      );
                    }
                )
            )
          ]
      ),
      floatingActionButton: new FloatingActionButton.extended(
        onPressed: () => navigateToExpense(context, n),
        splashColor: Color.fromARGB(255, 0, 245, 253),
        label: const Text('Добавить'),
        icon: const Icon(Icons.add_outlined),
        backgroundColor: Color.fromARGB(255, 60, 200, 250),
        elevation: 10,
        tooltip: "Добавьте ваши последние покупки",
      ),
    );
  }

  void navigateToExpense(BuildContext context, Expense expense) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateExpenseDialog(expense)),
    );

    if (result.isNotEmpty) {
      db.getAllExpenses().then((expenses) {
        setState(() {
          items.clear();
          expenses.forEach((expense) {
            items.add(Expense.fromMap(expense));
          });
        });
      });
      updating();
    } else {print("Ошибка");}
  }

  void deleteItem(BuildContext context, Expense expense, int index) async {
    db.delete(expense.id).then((_) {
      setState(() {
        items.removeAt(index);
      });
    });
    updating();
  }

  void updating(){
    db.summary().then((value){
      setState(() {
        if (value[0][0]["price"]==null){
          _price = 0;
        } else {
          _price = value[0][0]["price"];
        }
        _count = value[1][0]["count"];
      });
    });
  }
}


class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return MyAppState();
  }
}