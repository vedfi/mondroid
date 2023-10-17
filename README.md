[<img alt="mondroid-banner" src="https://user-images.githubusercontent.com/29797832/160253110-e3dcf46d-7c7e-4795-901a-c998f39d4cdd.jpg"/>]("https://user-images.githubusercontent.com/29797832/160253110-e3dcf46d-7c7e-4795-901a-c998f39d4cdd.jpg")

<a href='https://play.google.com/store/apps/details?id=com.vedfi.mondroid&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt="Get it on Google Play" height="75" src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/360px-Google_Play_Store_badge_EN.svg.png?20220907104002" width="250"/></a> &emsp; &emsp; <a href="https://www.buymeacoffee.com/vedfi" target="_blank"><img alt="Buy Me A Coffee" height="75" src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" width="250"/></a>

## About This Project
- The main goal of this project is providing a mongodb client for mobile devices. (Like official desktop client [Mongodb Compass](https://www.mongodb.com/products/compass))
- Mondroid is written in Flutter and utilizes [mongo_dart](https://github.com/mongo-dart/mongo_dart) driver.

## Features

### General
- Both mongodb:// and mongodb+srv:// connections are supported. ([Mongodb Connection Strings](https://www.mongodb.com/docs/manual/reference/connection-string/))
- Adding, removing, editing and reordering connection strings.
- Auto reconnecting.

### Collections
- Creating and deleting collections.
- Number of documents can be seen in each collection tile.

### Querying
- Find queries are supported in json format. ([Mongodb Query Operators](https://www.mongodb.com/docs/manual/reference/operator/query/))

### Documents
- CRUD operations are supported.
- On listing page; documents are represented in expandable tree format.
- On editing page; documents are represented in json string format.

### Custom Json Encoding / Decoding
Some data types are not supported by default json:convert library.
The following operators were used to support those types.

| Type                | Operator                 | Usage                                        |
|---------------------|--------------------------|----------------------------------------------|
| ObjectId            | $oid                     | "$oid:5a97f9c91c807bb9c6eb5fb4"              |
| DateTime            | $date                    | "$date:1998-11-02T01:30:00.000Z"             |
| Uuid                | $uuid                    | "$uuid:ddca6dd7-9887-4f56-8dea-264cbe1c15b1" |
| Decimal             | $decimal                 | "$decimal:2510.41"                           |
| NaN (Double)        | $doubleNaN               | "$doubleNaN"                                 |
| Infinity (Decimal)  | $decimalInfinity         | "$decimalInfinity"                           |
| Infinity (Double)   | $doubleInfinity          | "$doubleInfinity"                            |
| -Infinity (Decimal) | $decimalNegativeInfinity | "$decimalNegativeInfinity"                   |
| -Infinity (Double)  | $doubleNegativeInfinity  | "$doubleNegativeInfinity"                    |




## User Interface

<img src="https://github.com/vedfi/mondroid/assets/29797832/c8d834fa-2bf1-43a2-93bc-1cc519ecb7e6" width="225px">
<img src="https://github.com/vedfi/mondroid/assets/29797832/96b45456-f9da-47f4-b4aa-39f0bc167a52" width="225px">
<img src="https://github.com/vedfi/mondroid/assets/29797832/7d694b8b-3b88-4ce2-b5eb-e7ac2c12f611" width="225px">
<br>
<img src="https://github.com/vedfi/mondroid/assets/29797832/d0ee4cf7-8107-4dae-ac44-50be3974919b" width="225px">
<img src="https://github.com/vedfi/mondroid/assets/29797832/40173e40-be4d-4cb0-9124-06a5dd12bf77" width="225px">
<img src="https://github.com/vedfi/mondroid/assets/29797832/309e3f85-db48-4782-925e-9e2913cb6d1b" width="225px">

<!---
[<img alt="mondroid-ui-1" src="https://user-images.githubusercontent.com/29797832/160253540-c5acd9b4-cb72-4123-a10f-b72acf953ef3.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253540-c5acd9b4-cb72-4123-a10f-b72acf953ef3.jpg")
[<img alt="mondroid-ui-2" src="https://user-images.githubusercontent.com/29797832/160253541-5028dc41-df8c-41f7-9806-99b597cf85d4.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253541-5028dc41-df8c-41f7-9806-99b597cf85d4.jpg")
[<img alt="mondroid-ui-3" src="https://user-images.githubusercontent.com/29797832/160253542-d89d49b4-f80a-4f42-b2ac-065cd0635c46.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253542-d89d49b4-f80a-4f42-b2ac-065cd0635c46.jpg") -->

<!--- [<img alt="mondroid-ui-4" src="https://user-images.githubusercontent.com/29797832/160253543-f9339cac-17ce-4f1e-a4c3-877dbb219203.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253543-f9339cac-17ce-4f1e-a4c3-877dbb219203.jpg") -->

<!--- [<img alt="mondroid-ui-5" src="https://user-images.githubusercontent.com/29797832/160253545-c18cf30e-6290-4a16-8705-11f00eef6c17.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253545-c18cf30e-6290-4a16-8705-11f00eef6c17.jpg")
[<img alt="mondroid-ui-6" src="https://user-images.githubusercontent.com/29797832/160253546-9ebd8122-059d-4362-a97f-5b37a58d169d.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253546-9ebd8122-059d-4362-a97f-5b37a58d169d.jpg")
[<img alt="mondroid-ui-7" src="https://user-images.githubusercontent.com/29797832/160253547-3e943891-8d97-4654-bafb-d09fca38be80.jpg" width="225px"/>]("https://user-images.githubusercontent.com/29797832/160253547-3e943891-8d97-4654-bafb-d09fca38be80.jpg") -->

## Side Notes
I won't be able to develop full time; as this is a hobby project.
