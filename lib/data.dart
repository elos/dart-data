library data;

import "dart:async";
import "dart:convert" show JSON;
import "dart:html" show HttpRequest;

part 'src/interface.dart';
part 'src/memorydb.dart';
part 'src/restdb.dart';

dynamic JSONEncoder(Object item) {
  if (item is DateTime) {
    return item.toIso8601String();
  }
  return item;
}
