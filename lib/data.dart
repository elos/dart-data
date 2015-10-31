library data;

import "dart:async";
import "dart:mirrors";
import "dart:convert" show JSON;

part 'src/interface.dart';
part 'src/memorydb.dart';
part 'src/restdb.dart';

dynamic JSONEncoder(Object item) {
    if(item is DateTime) {
        return item.toIso8601String();
    }
    return item;
}
