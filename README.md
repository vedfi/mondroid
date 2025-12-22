<table>
  <tr>
    <td width="256" valign="center">
      <img width="256" height="256" alt="icon" src="https://github.com/user-attachments/assets/fced11df-8cbb-47d4-8bda-aa2c683c6679" />
    </td>
    <td valign="top">
      <h1>Mondroid - MongoDB Client</h1>
      <p>
        The main goal of the project is to bring a familiar MongoDB experience to iOS and Android.
      </p>
      <p>
        Inspired by the official desktop client:
        <a href="https://www.mongodb.com/products/compass">MongoDB Compass</a>
      </p>
      <p>
        The app is built with Flutter and uses the
        <a href="https://github.com/mongo-dart/mongo_dart">mongo_dart</a>
        driver under the hood.
      </p>
    </td>
  </tr>
  <tr>
    <td colspan=2 align="right">
      <p>
        <a href="https://apps.apple.com/us/app/mondroid/id6478081276?itscg=30200&itsct=apps_box_badge&mttnsubad=6478081276" style="display: inline-block; overflow: hidden; border-radius: 13px; width: 250px; height: 83px;"><img src="https://toolbox.marketingtools.apple.com/api/v2/badges/download-on-the-app-store/black/en-us?releaseDate=1709251200" alt="Download on the App Store" style="border-radius: 13px; width: 250px; height: 83px;" /></a>&nbsp;&nbsp;&nbsp;&nbsp;
<a href='https://play.google.com/store/apps/details?id=com.vedfi.mondroid&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt="Get it on Google Play" height="83" src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Google_Play_Store_badge_EN.svg/360px-Google_Play_Store_badge_EN.svg.png?20220907104002" width="276"/>
      </p>
    </td>
  </tr>
</table>

## Features

### General
- Both mongodb:// and mongodb+srv:// connections are supported. ([Mongodb Connection Strings](https://www.mongodb.com/docs/manual/reference/connection-string/))
- Adding, removing, editing and reordering connection strings.
- Auto reconnecting.

### Collections
- Creating and deleting collections.
- Number of documents can be seen in each collection tile.

### Querying
- Find queries are supported in json format. ([Mongodb Query Operators](https://www.mongodb.com/docs/manual/reference/mql/query-predicates/#std-label-query-predicates-ref))
- Sorting is also supported. ([Sorting Documents In Mongodb](https://www.mongodb.com/docs/manual/reference/operator/aggregation/sort/#mongodb-pipeline-pipe.-sort))

### Documents
- CRUD operations are supported.
- On listing page; documents are represented in expandable tree format.
- On editing page; documents are represented in json string format.

### Custom Json Encoding / Decoding
- Some data types are not supported by default json:convert library.
- The following operators were used to support those types.
- Please note that i don't recommend modifiying BsonBinary fields.
- Keep in mind that only Generic:(0) and LegacyUUID:(3) binary subtypes are supported. [(Binary Subtypes)](https://www.mongodb.com/docs/manual/reference/bson-types/#binary-data)
- Binary subtype 4 represents UUID and it is already available.

| Type                | Operator                 | Usage                                        |
|---------------------|--------------------------|----------------------------------------------|
| ObjectId            | $oid                     | "$oid:5a97f9c91c807bb9c6eb5fb4"              |
| DateTime            | $date                    | "$date:1998-11-02T01:30:00.000Z"             |
| Uuid                | $uuid                    | "$uuid:ddca6dd7-9887-4f56-8dea-264cbe1c15b1" |
| Long                | $long                    | "$long:300497"                               |
| Decimal             | $decimal                 | "$decimal:1102.98"                           |
| BsonBinary          | $binary                  | "$binary:3_ABCDEF" ("$binary: subType_value")|
| NaN (Double)        | $doubleNaN               | "$doubleNaN"                                 |
| Infinity (Decimal)  | $decimalInfinity         | "$decimalInfinity"                           |
| Infinity (Double)   | $doubleInfinity          | "$doubleInfinity"                            |
| -Infinity (Decimal) | $decimalNegativeInfinity | "$decimalNegativeInfinity"                   |
| -Infinity (Double)  | $doubleNegativeInfinity  | "$doubleNegativeInfinity"                    |

## User Interface

### Android
<img width="1200" height="1747" alt="github-android" src="https://github.com/user-attachments/assets/901e6daa-da1e-4d26-8922-0f1ae723972c" />


### iOS
<img width="1200" height="1710" alt="github-ios" src="https://github.com/user-attachments/assets/dc188e4b-911d-4c94-8fc8-7c0d66d1bffe" />


## Side Notes
- This is a hobby project, developed in my spare time.
- If you experience connection or authentication issues, please visit the [Help Center](https://vedfi.github.io/mondroid/help/connections/)
- If you enjoy using the app, consider leaving a rating on the App Store or Google Play.
