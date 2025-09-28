import 'package:mondroid/services/mongoservice.dart';

enum CollectionType {
  collection,
  view,
  time_series
}

class Collection {
  String name;
  int count = -2;
  CollectionType type;

  Collection(this.name, {this.type = CollectionType.collection});

  factory Collection.fromMongoCollection(MongoCollection collection) {
    CollectionType collectionType = switch (collection.type) {
      "view" => CollectionType.view,
      "timeseries" => CollectionType.time_series,
      _     => CollectionType.collection,
    };
    return Collection(collection.name,
        type: collectionType);
  }

  bool isReadonly() {
    return type == CollectionType.view;
  }
}
