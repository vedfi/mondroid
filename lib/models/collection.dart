import 'package:mondroid/services/mongoservice.dart';

enum CollectionType {
  collection,
  view,
}

class Collection {
  String name;
  int count = -2;
  CollectionType type;

  Collection(this.name, {this.type = CollectionType.collection});

  factory Collection.fromMongoCollection(MongoCollection collection) {
    return Collection(collection.name, type: collection.type == 'view' ? CollectionType.view : CollectionType.collection);
  }

  bool isReadonly(){
    return type == CollectionType.view;
  }
}
