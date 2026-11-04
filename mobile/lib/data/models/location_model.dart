class LocationModel {
  final int id;
  final int projectId;
  final String title;
  final String address;
  final double latitude;
  final double longitude;

  LocationModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      projectId: json['project_id'] is int ? json['project_id'] : int.parse(json['project_id'].toString()),
      title: json['title'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] is double ? json['latitude'] : double.parse(json['latitude'].toString()),
      longitude: json['longitude'] is double ? json['longitude'] : double.parse(json['longitude'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

