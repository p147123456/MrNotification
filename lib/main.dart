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
      title: '通知君',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: '通知君'),
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
  int _notificationSecond = 60;
  Future _incrementItem(BuildContext context) async {
    final _mFormKey = GlobalKey<FormState>();
    String _todoItem;
    DateTime _time = DateTime.now();
    return showDialog(
      context: context,
      barrierDismissible: false, //
      builder: (BuildContext context) {
        return StatefulBuilder(builder:(context,setState){
          return AlertDialog(
            title: Text('新增待辦事項',style: TextStyle(color: NColors.MainColor),),
            content: Form(
              key: _mFormKey,
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onSaved: (v){
                      _todoItem = v;
                    },
                    validator: (msg) {
                      if(msg.isEmpty) return "請輸入待辦事項";
                      return null;
                    } ,
                    decoration: new InputDecoration(
                      labelText: "請輸入待辦事項",
                      enabledBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(color: NColors.MainColor, width: 1.5),
                      ),
                      border: const OutlineInputBorder(),
                      labelStyle: new TextStyle(color: NColors.MainColor),
                    ),
                  ),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0))),
                          ),
                          onPressed: () {
                            DatePicker.showDateTimePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                maxTime: DateTime(DateTime.now().year+10, DateTime.now().month+10, DateTime.now().day+10),
                                onChanged: (date) {
                                  print('change $date');
                                }, onConfirm: (date) {
                                  setState(() {
                                    _time = date;
                                  });
                                  print('confirm $date');
                                }, currentTime: DateTime.now(), locale: LocaleType.zh);
                          },
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child:Text(
                              "${_time.year}年${_time.month}月${_time.day}日${_time.hour}點${_time.minute}分",
                              style: TextStyle(color: Colors.white),))))
                          ],),),
            actions: [
              TextButton(
                child: Text('確認',style: TextStyle(color: NColors.MainColor),),
                onPressed: () {
                  if(!_mFormKey.currentState.validate()) return;
                  _mFormKey.currentState.save();
                  todoItem data = new todoItem(todoitem: _todoItem,time: _time);
                  TodoListDBManager.instance.insertTodoItem(data);
                    mItemLst.add(data);
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('取消',style: TextStyle(color: NColors.MainColor),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
        );
      },
    );
  }
  Future _settingDlg(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, //
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('設定',style: TextStyle(color: NColors.MainColor),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            TextFormField(
              initialValue: _notificationSecond.toString(),
              inputFormatters: [
                new LengthLimitingTextInputFormatter(10),// for mobile
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
              onChanged: (v){
                _notificationSecond = int.tryParse(v);
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
                Record.writeIntByKey("NotificationSecond", _notificationSecond);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(onPressed:() =>_settingDlg(context).then((value) => _startTimer(_notificationSecond)),icon: Icon(
            Icons.settings,
            color: Colors.white,
          ),)
        ],
      ),
      body:Center(
        child: ListView.builder(
          itemCount: mItemLst.length,
            itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 10,
                  color: Colors.white,
                  child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      title: Text('${mItemLst[index].todoitem}'),
                      subtitle: Text('${mItemLst[index].time.year}年${mItemLst[index].time.month}月${mItemLst[index].time.day}日${mItemLst[index].time.hour}點${mItemLst[index].time.minute}分'),
                      trailing: IconButton(icon: Icon(Icons.delete),onPressed:() {
                        showDialog(
                          context: context,
                          barrierDismissible: false, //
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text('是否要刪除${mItemLst[index].todoitem}任務？'),
                              actions: [
                                TextButton(
                                  child: Text('確認',style: TextStyle(color: NColors.MainColor),),
                                  onPressed: () {
                                    TodoListDBManager.instance.deleteTodoItem(mItemLst[index].id);
                                    setState(() {mItemLst.remove(mItemLst[index]);});
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('取消',style: TextStyle(color: NColors.MainColor),),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }))
                ),
              );
      },)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:(){_incrementItem(context).then((value) {
          setState(() {

          });
        });},
        icon: Icon(Icons.add,color: Colors.white,size: 40,),
        label: Text('新增待辦事項'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    Record.init().then((value) {
      _notificationSecond = Record.readIntByKey("NotificationSecond");
    });
    LocalNotifications.instance.init();
    TodoListDBManager.instance.init().then((value){
      TodoListDBManager.instance.queryAllOTodoItem().then((value) => setState(() {
        mItemLst = value;
      }));
    });
    _startTimer(_notificationSecond);
  }

  void _startTimer(int second)
  {
    timer =new Timer.periodic(Duration(seconds: second), (timer)
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
              LocalNotifications.instance.show("提醒通知", "你的任務：${obj.todoitem}，時間已經到了!!快去做吧!!");
            }
          }
        }
    });
  }
}
