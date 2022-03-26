[<img alt="mondroid-banner" src="https://user-images.githubusercontent.com/29797832/160253110-e3dcf46d-7c7e-4795-901a-c998f39d4cdd.jpg"/>]("https://user-images.githubusercontent.com/29797832/160253110-e3dcf46d-7c7e-4795-901a-c998f39d4cdd.jpg")

## Goals Of This Project

- Providing a mongodb client for mobile devices. (Like official desktop client [Mongodb Compass](https://www.mongodb.com/products/compass))
- Supporting crud operations and basic querying.

## Features

### General
- Both mongodb:// and mongodb+srv:// connections are supported. ([Mongodb Connection Strings](https://www.mongodb.com/docs/manual/reference/connection-string/))
- Adding, removing and reordering connection strings.
- Naming connection strings.
- Auto reconnecting.

### Collections
- Creating and deleting collections.
- Number of documents can be seen in each collection tile.

### Querying
- Find queries are supported in json format. ([Mongodb Query Operators](https://www.mongodb.com/docs/manual/reference/operator/query/))

### Documents
- CRUD operations are supported.
- On listing page; documents are represented in master/detail tree format.
- On editing page; documents are represented in json string format.

### Custom Json Encoding / Decoding
Some data types are not supported by default json:convert library.
The following operators were used to support those types.

| Type     | Operator | Usage                                        |
|----------|----------|----------------------------------------------|
| DateTime | $date    | "$date:1998-11-02T01:30:00.000Z"             |
| ObjectId | $oid     | "$oid:5a97f9c91c807bb9c6eb5fb4"              |
| Uuid     | $uuid    | "$uuid:ddca6dd7-9887-4f56-8dea-264cbe1c15b1" |
| Round    | $decimal | "$decimal:2510.41"                           |

## User Interface

[<img alt="mondroid-ui-1" src="https://user-images.githubusercontent.com/29797832/160253540-c5acd9b4-cb72-4123-a10f-b72acf953ef3.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253540-c5acd9b4-cb72-4123-a10f-b72acf953ef3.jpg")
[<img alt="mondroid-ui-2" src="https://user-images.githubusercontent.com/29797832/160253541-5028dc41-df8c-41f7-9806-99b597cf85d4.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253541-5028dc41-df8c-41f7-9806-99b597cf85d4.jpg")
[<img alt="mondroid-ui-3" src="https://user-images.githubusercontent.com/29797832/160253542-d89d49b4-f80a-4f42-b2ac-065cd0635c46.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253542-d89d49b4-f80a-4f42-b2ac-065cd0635c46.jpg")
[<img alt="mondroid-ui-4" src="https://user-images.githubusercontent.com/29797832/160253543-f9339cac-17ce-4f1e-a4c3-877dbb219203.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253543-f9339cac-17ce-4f1e-a4c3-877dbb219203.jpg")

[<img alt="mondroid-ui-5" src="https://user-images.githubusercontent.com/29797832/160253545-c18cf30e-6290-4a16-8705-11f00eef6c17.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253545-c18cf30e-6290-4a16-8705-11f00eef6c17.jpg")
[<img alt="mondroid-ui-6" src="https://user-images.githubusercontent.com/29797832/160253546-9ebd8122-059d-4362-a97f-5b37a58d169d.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253546-9ebd8122-059d-4362-a97f-5b37a58d169d.jpg")
[<img alt="mondroid-ui-7" src="https://user-images.githubusercontent.com/29797832/160253547-3e943891-8d97-4654-bafb-d09fca38be80.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253547-3e943891-8d97-4654-bafb-d09fca38be80.jpg")


## Side Notes
I won't be able to develop full time; as this is a hobby project.
