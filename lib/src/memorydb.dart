part of data;

class MemoryDB implements DB {
    Map<String, Map<String, Map<String, dynamic>>> records;
    Map<String, RecordConstructor> kinds;

    MemoryDB() {
        this.records = new Map<String, Map<String, Map<String, dynamic>>>();
        this.kinds = new Map<String, RecordConstructor>();
    }

    String Type() => "memory";

    MemoryDB RegisterKind(String kind, String space, RecordConstructor rc) {
        this.kinds[kind] = rc;
        return this;
    }

    Map<String, Map<String, dynamic>> bucket(String kind) {
        Map<String, Map<String, dynamic>> bucket = this.records[kind];

        bucket ??= new Map<String, Map<String, dynamic>>();

        this.records[kind] = bucket;

        return bucket;
    }

    Future<Record> Save(Record r) {
        bucket(r.Kind())[r.ID()] = r.Structure();
        return new Future.value(r);
    }

    Future<Record> Delete(Record r) {
        bucket(r.Kind()).remove(r.ID());
        return new Future.value(r);
    }

    Future<Record> Find(String kind, String id) {
        RecordConstructor rc = this.kinds[kind];
        if (rc == null) {
            throw new StateError("Kind "  + kind + " not registered");
        }

        return new Future.value(rc(bucket(kind)[id]));
    }

    Query Query(String kind) {
        RecordConstructor rc = this.kinds[kind];
        if (rc == null) {
            throw new StateError("Kind "  + kind + " not registered");
        }

        return new MemQuery(this, rc, kind);
    }
}

typedef bool MatchFunc(Map<String, dynamic> s);

class MemQuery implements Query {
    final RecordConstructor c;
    final String kind;
    Stream<Map<String, dynamic>> stream;

    MemQuery(MemoryDB db, RecordConstructor this.c, String this.kind) {
        this.stream = new Stream.fromIterable(db.bucket(kind).values);
    }

    Stream<Record> Execute() {
        return this.stream.map(this.c);
    }

    MatchFunc match(String p, dynamic v) {
        bool matcher(Map<String, dynamic> s) {
            return s[p] == v;
        }

        return matcher;
    }

    Query Where(String property, dynamic value) {
        this.stream = this.stream.where(match(property, value));
        return this;
    }

    String Kind() => this.kind;
}
