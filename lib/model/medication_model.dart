class MedicationPillModel {
  String name;
  String time;
  String id;

  MedicationPillModel({
    required this.name,
    required this.time,
    required this.id,
  });

  factory MedicationPillModel.fromJson(Map<String, dynamic> json) {
    return MedicationPillModel(
      name: json['name'],
      time: json['time'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'time': time,
      'id': id,
    };
  }
}
