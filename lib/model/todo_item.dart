import 'package:hive/hive.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 1)
class TodoItem extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String task;
  @HiveField(2)
  String isComplete;

  TodoItem({this.id, this.task, this.isComplete});
}
