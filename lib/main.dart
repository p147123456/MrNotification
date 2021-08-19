import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrnotification/data/todoitem.dart';
import 'data/NColors.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'lib/Record.dart';
import 'lib/localnotifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  Timer timer;
  List<todoItem> mItemLst = [];
  int _notifiactionSecond = 60;
  Future _incrementItem(BuildContext context) async {
    String todoitem;
    DateTime time;
    return showDialog(
      context: context,
      barrierDismissible: false, //
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新增待辦事項',style: TextStyle(color: NColors.MainColor),),
          content: Column(children: [
            TextFormField(
              keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
              onChanged: (v){
                todoitem = v;
              },
              decoration: new InputDecoration(
                labelText: "請待辦事項",
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: NColors.MainColor, width: 1.5),
                ),
                border: const OutlineInputBorder(),
                labelStyle: new TextStyle(color: NColors.MainColor),
              ),
            ),
            TextButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                      maxTime: DateTime(DateTime.now().year+10, DateTime.now().month+10, DateTime.now().day+10),
                      onChanged: (date) {
                        print('change $date');
                      }, onConfirm: (date) {
                        time = date;
                        print('confirm $date');
                      }, currentTime: DateTime.now(), locale: LocaleType.zh);
                },
                child: Text(
                  '請選擇待辦事項時間',
                  style: TextStyle(color: Colors.blue),
                ))
          ],),
          actions: [
            TextButton(
              child: Text('確認',style: TextStyle(color: NColors.MainColor),),
              onPressed: () {
                todoItem data = new todoItem(todoitem: todoitem,time: time);
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
  Future _SettingDlg(BuildContext context) async {
    int seconds;
    return showDialog(
      context: context,
      barrierDismissible: false, //
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('設定',style: TextStyle(color: NColors.MainColor),),
          content: Column(children: [
            TextFormField(
              initialValue: _notifiactionSecond.toString(),
              inputFormatters: [
                new LengthLimitingTextInputFormatter(10),// for mobile
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
              onChanged: (v){
                seconds = int.tryParse(v);
              },
              decoration: new InputDecoration(
                labelText: "多久提醒一次(單位:秒)",
                enabledBorder: const OutlineInputBorder(
                  borderSide: const BorderSide(color: NColors.MainColor, width: 1.5),
                ),
                border: const OutlineInputBorder(),
                labelStyle: new TextStyle(color: NColors.MainColor),
              ),
            ),
          ],),
          actions: [
            TextButton(
              child: Text('確認',style: TextStyle(color: NColors.MainColor),),
              onPressed: () {
                Record.writeIntByKey("NotificationSecond", seconds);
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
                  _SettingDlg(context);
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
              trailing: IconButton(icon: Icon(Icons.delete),onPressed:() {
                TodoListDBManager.instance.deleteTodoItem(mItemLst[index].id);
                setState(() {mItemLst.remove(mItemLst[index]);});
              }));
      },)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:(){_incrementItem(context);},
        icon: Icon(Icons.add,color: Colors.white,size: 40,),
        label: Text('新增待辦事項'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    Record.init().then((value) => null);
    LocalNotifications.instance.init();
    TodoListDBManager.instance.init().then((value){
      TodoListDBManager.instance.queryAllOTodoItem().then((value) => mItemLst = value);
    });
    _startTimer();
  }

  void _startTimer()
  {
    timer = Timer.periodic(Duration(seconds: _notifiactionSecond), (timer)
    {
      for(var obj in mItemLst)
        {
          //如果是今天
          if(obj.time.year==DateTime.now().year && obj.time.month == DateTime.now().month && obj.time.day == DateTime.now().day)
          {
            int TargetMinuteAmount = (obj.time.hour*60) + (obj.time.minute);
            int NowMinuteAmount = (DateTime.now().hour*60) + (DateTime.now().minute);
            if(NowMinuteAmount >= TargetMinuteAmount)
            {
              LocalNotifications.instance.show("提醒通知", "你的任務${obj.todoitem}時間已經到了!!快去做吧!!");
            }
          }
        }
    });
  }
}
