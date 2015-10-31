part of data;

abstract class Host {
    Future<HttpRequest> GET(String url, dynamic data);
    Future<HttpRequest> POST(String url, dynamic data);
    Future<HttpRequest> DELETE(String url, dynamic data);
}

class RestDB implements DB {
    final Host host;
    MemoryDB cache;
    Map<String, String> spaces;
    Map<String, RecordConstructor> constructors;

    RestDB(Host this.host) {
        this.cache = new MemoryDB();
        this.spaces = new Map<String, String>();
        this.constructors = new Map<String, RecordConstructor>();
    }

    String Type() => "rest";

    RestDB RegisterKind(String kind, String space, RecordConstructor rc) {
        this.cache.RegisterKind(kind, space, rc);
        this.spaces[kind] = space;
        this.constructors[kind] = rc;

        return this;
    }

    Future<Record> Save(Record r) async {
        var completer = new Completer<Record>();

        Future<HttpRequest> req = this.host.POST("/${this.spaces[r.Kind()]}", r.Structure());

        req.then( (req) {
            if (req.status == 200 || req.status == 201) {
                Map<String, dynamic> response = JSON.decode(req.response);
                print(response);
                completer.complete(constructors[r.Kind()](response["data"][r.Kind()]));
            } else {
                completer.completeError('shit');
            }
        },
        onError: (e) {
            print(e.target.responseText);
            print(e.target.response);
            print(e.target.readyState);
            print(e.target.status);
            completer.completeError('NOOO');
        });

        return completer.future;
    }

    Future<Record> Delete(Record r);

    Future<Record> Find(String kind, String id) async {
        var completer = new Completer<Record>();

        Future<HttpRequest> req = this.host.GET("/${this.spaces[kind]}?${kind}_id=${id}", {'${kind}_id': id});

        req.then( (req) {
            if (req.status == 200 || req.status == 201) {
                Map<String, dynamic> response = JSON.decode(req.response);
                completer.complete(constructors[kind](response["data"][kind]));
            } else {
                completer.completeError('shit');
            }
        },
        onError: (e) {
            print(e.target.responseText);
            completer.completeError('NOOO');
        });

        return completer.future;
    }

    Query Query(String kind);
}
