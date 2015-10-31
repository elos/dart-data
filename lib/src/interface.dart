part of data;

// The abstract interface for all implementations of
// data records.
abstract class Record {
    // Decoding
    Record.fromStructure(Map<String, dynamic> s);

    // The unique identifier of this record
    String ID();

    // The kind of this record, unique to all records of this kind.
    String Kind();

    // Encoding
    Map<String, dynamic> Structure();
}

typedef Record RecordConstructor(Map<String, dynamic> structure);

// A query over records and their properties.
// A query is scoped to a particular kind.
abstract class Query {
    String Kind();

    // Where provides selection over the set of records
    Query Where(String property, dynamic value);

    // This will execute the query as it has been built up.
    Stream<Record> Execute();
}

abstract class DB {
    // The type of the database, a pseudo-replacement for reflection.
    String Type();

    DB RegisterKind(String kind, String space, RecordConstructor rc);

    Future<Record> Save(Record);

    Future<Record> Delete(Record);

    Future<Record> Find(String kind, String id);

    // Create a new query over a particular kind of record.
    Query Query(String kind);
}
