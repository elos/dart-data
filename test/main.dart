library data.test;

import "dart:async";

import 'package:test/test.dart';
import 'package:data/data.dart';

class R implements Record {
    String kind;
    String id;
    String name;

    R(this.kind, this.id, this.name);

    R.fromStructure(Map<String, dynamic> s) {
        this.kind = s['kind'];
        this.id = s['id'];
        this.name = s['name'];
    }

    Map<String, dynamic> Structure() {
        return {
            "kind": this.kind,
            "id": this.id,
            "name": this.name,
        };
    }

    String ID() => this.id;
    String Kind() => this.kind;
}

void main() {
    test('test memory db', () async {
        DB memdb = new MemoryDB();
        var f = (Map<String, dynamic> s) => new R.fromStructure(s);
        memdb.RegisterKind("test", "tests", f);

        Record r = new R("test", "1", "foo");
        Record r2 = new R("test", "2", "foo");
        Record r3 = new R("test", "3", "bar");

        memdb.Save(r);
        memdb.Save(r2);
        memdb.Save(r3);

        var retrieved = await memdb.Find("test", "1");

        expect(retrieved.id, "1");

        Query q = memdb.Query("test");
        Stream<Record> records =  q.Where("name", "foo").Execute();

        Future<List<Record>> future = records.toList();
        var foos = await future;

        expect(foos.length, 2);
    });
}

