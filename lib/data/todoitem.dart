import 'package:mrnotification/lib/DatabaseHelper.dart';
class todoItem{
  //資料庫主鍵
  int id=-1;
  String todoitem='';
  DateTime time ;


  todoItem({this.id,this.todoitem,this.time,});

  todoItem fromJson(Map<String, dynamic> map) {
    this.id=map["id"];
    this.todoitem=map["todoitem"];
    this.time=DateTime.tryParse(map["time"]) ;
    return this;
  }

  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'todoitem': todoitem,
      'time' : time.toIso8601String(),
    };
  }
}

class TodoListDBManager extends DatabaseHelper{
  //region Singleton 單例模式，確保一個類別只有一個實例
  TodoListDBManager._() {}
  static final TodoListDBManager instance = TodoListDBManager._();
  //endregion
  final int dbver = 1 ;
  Future<void> init() async
  {
    await this.initDB(dbver) ;
  }

  final String todolistTable = "todolist" ;

  //插入資料
  void insertTodoItem(todoItem _todoItem) async {
    int idx = await this.insertRecord(todolistTable,_todoItem.toJson());
    print('--- insert 執行結束---' );
  }

  //查詢資料
  Future<List<todoItem>> queryAllOTodoItem() async {
    List<todoItem> data = new List<todoItem>();
    final rows = await queryAll(todolistTable);
    if(rows == null) return data;
    print('查詢結果:$rows');
    rows.forEach((row) => data.add(new todoItem().fromJson(row)));
    print('--- query 執行結束---');
    return data;
  }

  //更新資料
  void updateTodoItem(todoItem _todoItem) async {
    this.updateRecord(todolistTable, _todoItem.toJson(), "id=?", [_todoItem.id]) ;
    print('--- update 執行結束---');
  }

  //刪除資料
  void deleteTodoItem(int id) async {
    this.deleteRecord(todolistTable, "id = ?",[id]);
    print('--- delete 執行結束---');
  }

  //刪除所有資料
  void deleteAllTodoItem() async {
    super.deleteAll(todolistTable);
    print('--- deleteAll 執行結束---');
  }
  @override
  // TODO: implement localdbName
  String get localdbName => "assets/TodoList.db";
}