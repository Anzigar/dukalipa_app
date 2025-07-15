class DeviceEntryModel {
  final String? serialNumber;
  final String? imei;
  final String color;
  final String storage;
  final String condition;
  final String? notes;

  const DeviceEntryModel({
    this.serialNumber,
    this.imei,
    required this.color,
    required this.storage,
    required this.condition,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'serial_number': serialNumber,
      'imei': imei,
      'color': color,
      'storage': storage,
      'condition': condition,
      'notes': notes,
    };
  }

  factory DeviceEntryModel.fromJson(Map<String, dynamic> json) {
    return DeviceEntryModel(
      serialNumber: json['serial_number'],
      imei: json['imei'],
      color: json['color'] ?? '',
      storage: json['storage'] ?? '',
      condition: json['condition'] ?? 'New',
      notes: json['notes'],
    );
  }

  DeviceEntryModel copyWith({
    String? serialNumber,
    String? imei,
    String? color,
    String? storage,
    String? condition,
    String? notes,
  }) {
    return DeviceEntryModel(
      serialNumber: serialNumber ?? this.serialNumber,
      imei: imei ?? this.imei,
      color: color ?? this.color,
      storage: storage ?? this.storage,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'DeviceEntry(serial: $serialNumber, color: $color, storage: $storage)';
  }
}
