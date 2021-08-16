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
    //提前幾號提醒
    int remindNum=3;
    return showDialog(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('新增任務',style: TextStyle(color: NColors.MainColor),),
          content: TextFormField(
            //initialValue:ConfigInfo.remindNum.toString(),
            inputFormatters: [
              new LengthLimitingTextInputFormatter(2),// for mobile
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            keyboardType: TextInputType.numberWithOptions(decimal: true,signed: true),
            onChanged: (v){
              remindNum=int.tryParse(v);
            },
            decoration: new InputDecoration(
              labelText: "提前幾號提醒",
              enabledBorder: const OutlineInputBorder(
                borderSide: const BorderSide(color: NColors.MainColor, width: 1.5),
              ),
              border: const OutlineInputBorder(),
              labelStyle: new TextStyle(color: NColors.MainColor),
            ),
          ),
          actions: [
            FlatButton(
              child: Text('確認',style: TextStyle(color: NColors.MainColor),),
              onPressed: () {
                //ConfigInfo.remindNum = remindNum;
                //XRecord.writeIntByKey('remindNum', remindNum);
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
      backgroundColor: Colors.white70,
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
                  _asyncInputDialog(context);
                  break;
              }
            },
          )
        ],
      ),
      body:Column(children: [
        Container(
          child:Text('${DateTime.now()}'),
          decoration: new BoxDecoration(
            border: new Border.all(color: Colors.grey, width: 0.5), // 边色与边宽度底色
            //        borderRadius: new BorderRadius.circular((20.0)), // 圆角度
            borderRadius: new BorderRadius.vertical(top: Radius.elliptical(20, 50)), // 也可控件一边圆角大小
          ),
        ),
        SizedBox(height: 10,),
        Expanded(child:
        Container(
          child:ListView(children: [
            ListView.separated(
              physics: ScrollPhysics(),
              reverse: true,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, kFloatingActionButtonMargin + 48),
              itemCount: mItemLst.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)),),
                        // 抗鋸齒
                        clipBehavior: Clip.antiAlias,
                        elevation: 20,
                        // 陰影大小
                        child: new Container(
                          alignment: Alignment.center,
                          child: new ListTile(
                            title: Column(
                              children: [
                                Text("${mItemLst[i].todoitem}",style: TextStyle(fontSize: 30,color: Colors.white),),
                              ],),
                          ),
                        )));
              }, separatorBuilder: (BuildContext context, int index) {
              return Divider(thickness: 0);
            },
            ),
          ],),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white
          ),
        )
        )
      ],),

      floatingActionButton: FloatingActionButton.extended(
        onPressed:(){_incrementItem(context);},
        icon: Icon(Icons.add,color: Colors.white,size: 40,),
        label: Text('新增任務'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
