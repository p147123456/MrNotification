import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrnotification/data/todoitem.dart';

import 'data/NColors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr Notification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mr Notification'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<todoItem> mItemLst = [];
  Future _incrementItem(BuildContext context) async {
    String todoitem;
    return showDialog(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新增任務',style: TextStyle(color: NColors.MainColor),),
          content: TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
            onChanged: (v){
              todoitem = v;
            },
            decoration: new InputDecoration(
              labelText: "請輸入待辦事項",
              enabledBorder: const OutlineInputBorder(
                borderSide: const BorderSide(color: NColors.MainColor, width: 1.5),
              ),
              border: const OutlineInputBorder(),
              labelStyle: new TextStyle(color: NColors.MainColor),
            ),
          ),
          actions: [
            TextButton(
              child: Text('確認',style: TextStyle(color: NColors.MainColor),),
              onPressed: () {
                todoItem data = new todoItem(todoitem: todoitem,time: DateTime.now());
                TodoListDBManager.instance.insertTodoItem(data);
                setState(() {
                  mItemLst.add(data);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            itemBuilder: (BuildContext bc) => [
              PopupMenuItem(child: Text("設定"), value: "/Setting"),
            ],
            onSelected: (route) {
              switch(route){
                case "/Setting":
                  //_asyncInputDialog(context);
                  break;
              }
            },
          )
        ],
      ),
      body:Center(
    child: ListView.builder(
    itemCount: mItemLst.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('${mItemLst[index].todoitem}'),
          subtitle: Text('${mItemLst[index].time}'),
          trailing: IconButton(icon: Icon(Icons.delete),onPressed:(){
            TodoListDBManager.instance.deleteTodoItem(mItemLst[index].id);
            setState(() {mItemLst.remove(mItemLst[index]);
            });
            })
        );
      },
    )),

      floatingActionButton: FloatingActionButton.extended(
        onPressed:(){_incrementItem(context);},
        icon: Icon(Icons.add,color: Colors.white,size: 40,),
        label: Text('新增任務'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void initState() {
    TodoListDBManager.instance.init().then((value){
      TodoListDBManager.instance.queryAllOTodoItem().then((value) => mItemLst = value);
    });

  }
}
