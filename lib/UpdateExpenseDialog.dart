import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ExpenseDB.dart';
import 'Expense.dart';


class UpdateExpenseDialogState extends State<UpdateExpenseDialog> {
  GlobalKey<FormState> _formState = GlobalKey<FormState>();
  ExpenseDB db = new ExpenseDB();

  Expense expense;
  TextEditingController name;
  TextEditingController price;
  bool checkBoxValue = false;
  String t;
  bool adding;
  String _name;
  double _price;
  String date;
  String tempDate;

  @override
  void initState() {
    super.initState();
    if (widget.expense == null) {
      date = DateFormat('dd.MM.yyyy').format(DateTime.now());
      t = "Добавить покупку";
      tempDate = date;
      adding = true;
    } else {
      date = widget.expense.date;
      name = new TextEditingController(text: widget.expense.name);
      price = new TextEditingController(text: widget.expense.price.toString());
      tempDate = date;
      t = "Изменить покупку";
      adding = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(t),
            centerTitle: true,
            backgroundColor: Color.fromARGB(200, 60, 200, 250)),
        body: SingleChildScrollView(physics: BouncingScrollPhysics(), child: Center(child:
        Container(
            margin: EdgeInsets.all(4),
            width: 350,
            height: 700,
            child:
            Form(
              key: _formState,
              child: Column(children: [
                Container(margin: EdgeInsets.only(top: 30, bottom: 10),child:Text("Название", style: TextStyle(fontSize: 30))),
                Visibility(child: Container(child:TextFormField(
                                        decoration: InputDecoration(fillColor: Color.fromARGB(20, 72, 176, 212), filled: true),
                                        style: TextStyle(fontSize: 30),
                                        onChanged: (value) {_name = value;},
                                  ),
                              ),
                            visible: adding),
                Visibility(child: TextFormField(
                                        controller: name,
                                        decoration: InputDecoration(fillColor: Color.fromARGB(20, 72, 176, 212), filled: true),
                                        style: TextStyle(fontSize: 30),
                                  ),
                            visible: !adding),
                Container(margin: EdgeInsets.only(top: 30, bottom: 10),child:Text("Цена", style: TextStyle(fontSize: 30))),
                Visibility(child: TextFormField(
                    decoration: InputDecoration(fillColor: Color.fromARGB(20, 72, 176, 212), filled: true),
                    style: TextStyle(fontSize: 30),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {_price = double.parse(value);},
                    validator: (value) {
                      try {
                        if (value.contains(",")){return "Исправьте знак ',' на '.'";}
                        if (value.isEmpty || double.tryParse(value) < 0.0){
                          return "Введите сумму покупки";
                        } return null;
                      } catch (e){
                        return "Введите сумму покупки";
                      }
                    }),
                    visible: adding,),
                Visibility(child: TextFormField(
                    controller: price,
                    decoration: InputDecoration(fillColor: Color.fromARGB(20, 72, 176, 212), filled: true),
                    style: TextStyle(fontSize: 30),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      try {
                        if (value.contains(",")){return "Исправьте знак ',' на '.'";}
                        if (value.isEmpty || double.tryParse(value) < 0.0){
                          return "Введите сумму покупки";
                        } return null;
                      } catch (e){
                        return "Введите сумму покупки";
                      }
                    }),
                  visible: !adding,),
                Container(margin: EdgeInsets.only(top: 20, bottom: 10),child:Text("Дата", style: TextStyle(fontSize: 30))),
                Container(
                  padding: EdgeInsets.only(top: 10.0, left: 15),
                  child: Row(
                    children: <Widget>[
                      Checkbox(value: checkBoxValue,
                          activeColor: Colors.indigoAccent,
                          onChanged:(bool newValue){
                            setState(() {
                              if (checkBoxValue){
                                checkBoxValue = false;
                                if (adding){ tempDate = DateFormat('dd.MM.yyyy').format(DateTime.now()); }
                                  else {tempDate = date;}
                              } else {
                                checkBoxValue = true;

                                showDatePicker(context: context,
                                    initialDate: tempDate == null ? DateFormat('dd.MM.yyyy').parse(date) : DateFormat('dd.MM.yyyy').parse(tempDate),
                                    firstDate: DateTime(2010),
                                    lastDate: DateTime(2210)
                                ).then((_date){
                                  setState(() {
                                    if (_date != null){
                                    tempDate = DateFormat('dd.MM.yyyy').format(_date).toString();}
                                    else {tempDate = date;}
                                  });
                                });
                              }
                            });
                          }),
                      Visibility(child: Container(padding: EdgeInsets.only(top:5,bottom:5,left: 40, right:55),
                        alignment:Alignment.center,
                        color:Color.fromARGB(20, 72, 176, 212),
                        child:Text("\t \t \t$date\nУстановить другую?",
                            style: TextStyle(fontSize: 20)),
                      ),
                          visible: !checkBoxValue
                      ),
                      Visibility(
                        child: Container(padding: EdgeInsets.only(top:5,bottom:5,left: 30, right:120),
                          alignment:Alignment.center,
                          color:Color.fromARGB(20, 72, 176, 212),
                          child:Text("Выбрана дата:\n \t $tempDate", style: TextStyle(fontSize: 20)),
                        ),
                        visible: checkBoxValue,
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(30),
                    child: Column(children: [
                          Visibility(child: TextButton(
                              child: Text('Подтвердить'),
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                                backgroundColor: Color.fromARGB(255, 60, 200, 250),
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30)),
                                elevation: 10,
                                textStyle: TextStyle(fontSize: 20),
                                padding: EdgeInsets.all(10),
                              ),
                              onPressed: () {
                                if (_name != null && _price != null){
                                  db.saveExpense(_name, _price, tempDate).then((_) {
                                    Navigator.pop(context, 'save');
                                  });
                                } else {
                                  Navigator.pop(context);
                                }
                              }),
                              visible: adding),
                          Visibility(child: TextButton(
                              child: Text('Обновить'),
                              style: TextButton.styleFrom(
                                primary: Colors.black,
                                backgroundColor: Color.fromARGB(255, 60, 200, 250),
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30)),
                                elevation: 10,
                                textStyle: TextStyle(fontSize: 20),
                                padding: EdgeInsets.all(10),
                              ),
                              onPressed: () {
                                if (name != null && price != null){
                                  db.updateExpense(name.text, price.text, widget.expense.id, tempDate).then((_) {
                                    Navigator.pop(context, 'update');
                                  });
                                } else {
                                  Navigator.pop(context);
                                }
                              }),
                          visible: !adding)
                    ]))
              ]),
            )
        )
        ))
    );
  }
}

class UpdateExpenseDialog extends StatefulWidget {
  Expense expense;
  UpdateExpenseDialog(this.expense);

  @override
  State<StatefulWidget> createState() {
    return UpdateExpenseDialogState();
  }
}