<p align="center">
<img src="logo.png" width="150" max-width="50%" alt="Fox Labs" />
</p>

<p align="center">
<a href="https://github.com/Nickelfox">Fox Labs</a>
|
<a href="https://github.com/Nickelfox/JSONParsing">JSONParsing</a>
</p>

<p align="center">
<a href="https://cocoapods.org/pods/JSONParsing">
<img src="https://img.shields.io/cocoapods/v/JSONParsing.svg" alt="CocoaPods" />
</a>
<a href="https://github.com/Carthage/Carthage">
<img src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat" alt="Carthage" />
</a>
<a href="https://nickelfox.com">
<img src="https://img.shields.io/badge/contact-nickelfox.com-E2142D.svg" alt="Website: https://nickelfox.com" />
</a>
</p>

`JSONParsing` is a wrapper around SwiftyJSON to Parse JSON with even more understandability.

# Usage

Let’s take an example of a `JSON`: 

```json
{
"name": "John",
"age": 27
}
```

To parse(or to say de-serialize) this `JSON`, create a class:

```swift
final public class User {
var name: String
var age: Int

init(name: String, age: Int) {
self.name = name
self.age = age
}
}
```

and confirm this class to `JSONParseable` protocol

```swift
extension User: JSONParseable {
public static func parse(_ json: JSON) throws -> User {
return try User(name: json["name"]^,
age: json["age"]^)
}  
}
```

To Serialize(encode) User object to this JSON:

```swift
extension User {
public var toJSON: [String: Any] {
["name": self.name,
"age": self.age]
}
```

## Operators
- `^` to infer and parse associated non optional data types automatically.
- `^^` to infer and parse array values of any type automatically.
- `^?` to infer and parse optional values
- `^!` to try to force parse json value into respective data type.

# Advanced Examples

### Nested JSON
Let’s take another example of a complex `JSON`: 

```json
{
"name": "John",
"age": 27,
"address": {
"house_number": "B51",
"street": "Street 21",
"city": "Woodland",
"country": "Singapore"
}
}
```

To parse this `JSON`, create two different classes like this:

```swift
final public class User {
var name: String
var age: Int
var address: Address

init(name: String, age: Int, address: Address) {
self.name = name
self.age = age
self.address = address
}
}

final public class Address {
var houseNumber: String
var street: String
var city: String
var country: String

init(houseNumber: String, street: String, city: String, country: String) {
self.houseNumber = houseNumber
self.street = street
self.city = city
self.country = country
}
}
```

and confirm to protocol `JSONParseable` like this:

```swift
extension User: JSONParseable {
public static func parse(_ json: JSON) throws -> User {
return try User(name: json["name"]^,
age: json["age"]^,
address: json["address"]^)
}  
}

extension Address: JSONParseable {
public static func parse(_ json: JSON) throws -> Address {
return try User(houseNumber: json["house_number"]^,
street: json["street"]^,
city: json["city"]^,
country: json["country"]^)
}
}
```

### Nested JSON with Array
Another example of a more complex `JSON`:

```json
{
"name": "John",
"age": 27,
"addresses": [
{
"house_number": "B51",
"street": "Street 21",
"city": "Woodland",
"country": "Singapore"
},
{
"house_number": "C42",
"street": "Street 21",
"city": "Woodland",
"country": "Singapore"
},
{
"house_number": "71",
"street": "Street 82",
"city": "Woodland",
"country": "Singapore"
}
]
}
```

To parse this `JSON`, create two different classes like this:

```swift
final public class User {
var name: String
var age: Int
var address: [Address]

init(name: String, age: Int, address: Address) {
self.name = name
self.age = age
self.address = address
}
}

final public class Address {
var houseNumber: String
var street: String
var city: String
var country: String

init(houseNumber: String, street: String, city: String, country: String) {
self.houseNumber = houseNumber
self.street = street
self.city = city
self.country = country
}
}
```

and confirm to protocol `JSONParseable` like this:

```swift
extension User: JSONParseable {
public static func parse(_ json: JSON) throws -> User {
return try User(name: json["name"]^,
age: json["age"]^,
address: json["addresses"]^^)
}  
}

extension Address: JSONParseable {
public static func parse(_ json: JSON) throws -> Address {
return try User(houseNumber: json["house_number"]^,
street: json["street"]^,
city: json["city"]^,
country: json["country"]^)
}
}
```
# Transformations

`JSONParsing` also supports transformations that let you treat any value or object as if it was a raw JSON type.

It comes with default `String -> URL` transformation, which lets you parse any URL property from a string describing an URL without writing any transformation code.

And so is for `String -> Int, Double, Float` transformations. If you’re parsing a number type and a string was found, that string will automatically be converted to that number type (if possible).

To enable your own types to be `parseable` using a transformation, all you have to do is make your type conform to `JSONParseTransformable` and implement its protocol methods.

Here’s an example that makes `Date` type `parseable` using a transformation:

To parse `Date`, first confirm `Date` to `JSONParseTransformable`:

```swift
extension Date: JSONParseTransformable {

public typealias RawValue = String

public static func transform(_ value: String) -> Date? {
let formatter = DateFormatter()
formatter.dateFormat = "d MMM, yyyy"
return formatter.date(from: value)
}
}
```

Now, let's take an example of a class `User`:

```swift
final public class User {
var name: String
var age: Int
var dob: Date?

init(name: String, age: Int, dob: Date?) {
self.name = name
self.age = age
self.date = date
}
}
```

and confirm this class to `JSONParseable` protocol

```swift
extension User: JSONParseable {
public static func parse(_ json: JSON) throws -> User {
return try User(name: json["name"]^,
age: json["age"]^),
date: Date.transform(json["dob"]^)
}  
}
```

## Supported types

JSONParsing supports parsing of all standard `JSON` types, like:

- Bool
- Int, Double, Float
- String
- Array
- Dictionary
- URL

It also supports all possible combinations of nested arrays & dictionaries as you can see in the examples above.

Finally, it also supports `associated types` through the use of a transformer, if required confirm that type to JSONParseTransformable, just like the example above to parse `Date`.

## Installation
#### <i class="icon-file"></i>**CocoaPods**
[CocoaPods](https://cocoapods.org) is the dependency manager for Cocoa Libraries. You can install Cocoapods using the following command:

> `$ sudo gem install cocoapods`

If you wish to integrate `JSONParsing` in your project, then make following changes in your `Podfile`:

```  
platform :ios, '9.0'
use_frameworks!
target 'YourAppName' do
pod 'JSONParsing'
end
```

After saving `Podfile`. Run the following command:

pod install

#### <i class="icon-pencil"></I>**Manually**
If you don't want to use any dependency manager in your project, you can install this library manually too.
Just download and add the `Source` folder to your project.




