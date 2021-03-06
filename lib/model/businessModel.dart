class BusinessModel {
  BusinessModel({
    this.businessStatus,
    this.icon,
    this.name,
    this.place_id,
    this.vicinity,
    this.scope,
    this.lat,
    this.long,
  });

  String businessStatus;
  String icon;
  String name;
  String place_id;
  String vicinity;
  String scope;
  double lat;
  double long;

  Map<String, dynamic> toJson() => {
        "businessStatus": businessStatus == null ? null : businessStatus,
        "icon": icon == null ? null : icon,
        "name": name == null ? null : name,
        "place_id": place_id == null ? null : place_id,
        "scope": scope == null ? null : scope,
        "vicinity": vicinity == null ? null : vicinity,
        "lat": lat == null ? null : lat,
        "long": long == null ? null : long,
      };

  factory BusinessModel.fromJson(Map<String, dynamic> json) => BusinessModel(
        businessStatus: json["businessStatus"] == null ? null : json["businessStatus"],
        icon: json["icon"] == null ? null : json["icon"],
        name: json["name"] == null ? null : json["name"],
        place_id: json["place_id"] == null ? null : json["place_id"],
        scope: json["scope"] == null ? null : json["scope"],
        vicinity: json["vicinity"] == null ? null : json["vicinity"],
        lat: json["lat"] == null ? null : json["lat"],
        long: json["long"] == null ? null : json["long"],
      );
}
