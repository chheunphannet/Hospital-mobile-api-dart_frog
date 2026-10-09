import 'package:mongo_dart/mongo_dart.dart';

class Branches {
  final String? id;
  final String name;
  final String code;
  final List<String> contactNumbers;
  final String email;
  final String address;
  final Location location;
  final List<Room> rooms;
  final List<Hardware> hardwares;

  const Branches({
    this.id,
    required this.name,
    required this.code,
    required this.contactNumbers,
    required this.email,
    required this.address,
    required this.location,
    required this.rooms,
    required this.hardwares,
  });

  factory Branches.fromJson(Map<String, dynamic> json) => Branches(
    id: json['id'] != null ? (json['id'] as ObjectId).oid : null,
    name: json['name'] as String,
    code: json['code'] as String,
    contactNumbers: (json['contactNumbers'] as List<dynamic>)
        .map((number) => number as String)
        .toList(),
    email: json['email'] as String,
    address: json['address'] as String,
    location: Location.fromJson(json['location'] as Map<String, dynamic>),
    rooms: (json['rooms'] as List<dynamic>)
        .map((item) => Room.fromJson(item as Map<String, dynamic>))
        .toList(),
    hardwares: (json['hardware'] as List<dynamic>)
        .map((item) => Hardware.fromJson(item as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'contactNumbers': contactNumbers,
    'email': email,
    'address': address,
    'location': location.toJson(),
    'rooms': rooms.map((room) => room.toJson()).toList(),
    'hardware': hardwares.map((item) => item.toJson()).toList(),
  };
}

class Location {
  final String type;
  final List<double> coordinates;

  const Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json['type'] as String,
    coordinates: (json['coordinates'] as List)
        .map((e) => (e as num).toDouble())
        .toList(),
  );

  Map<String, dynamic> toJson() => {'type': type, 'coordinates': coordinates};
}

class Room {
  final String type;
  // final String roomNum;
  final List<String> roomPhotos;
  final String context;

  const Room({
    required this.type,
    required this.context,
    required this.roomPhotos,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    type: json['type'] as String,
    roomPhotos: (json['roomPhotos'] as List<dynamic>)
        .map((photo) => photo as String)
        .toList(),
    context: json['context'] as String,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'roomPhotos': roomPhotos,
    'context': context,
  };
}

class Hardware {
  final String name;
  final String context;
  final List<String> hardwarePhotoes;

  const Hardware({
    required this.name,
    required this.context,
    required this.hardwarePhotoes,
  });

  factory Hardware.fromJson(Map<String, dynamic> json) => Hardware(
    name: json['name'] as String,
    context: json['context'] as String,
    hardwarePhotoes: (json['hardwarePhotoes'] as List<dynamic>)
        .map((photo) => photo as String)
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'context': context,
    'hardwarePhotoes': hardwarePhotoes,
  };
}
