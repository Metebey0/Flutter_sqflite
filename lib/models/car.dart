import 'package:fluttersqfliteexample/utils/dbhelper.dart';

class Car {
  int? id;
  String? name;
  int? miles;

  Car(this.id, this.miles, this.name);

  Car.fromMap(Map<String,dynamic> map) {
    id = map['id'];
    name = map['name'];
    miles = map['miles'];
  }

  Map<String, dynamic> toMap() {
    return{
      DatabaseHelper.columnId :  id,
      DatabaseHelper.columnName : name,
      DatabaseHelper.columnMiles : miles,

    };
  }
}