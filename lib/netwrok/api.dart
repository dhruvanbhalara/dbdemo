import 'package:db/db/dbProvider.dart';
import 'package:db/model/businessModel.dart';
import 'package:db/model/mapListModel.dart';
import 'package:dio/dio.dart';

class ApiProvider {
  Future getAllBusiness() async {
    var url =
        "https://maps.googleapis.com/maps/api/place/search/json?location=23.03744,72.566&rankby=distance&types=bakery&sensor=true&key=AIzaSyB2Az9gVUzQULUc55xQD9AE7gj9Ni5hvJk";
    Response response = await Dio().get(url);

    if (response.statusCode == 200) {
      MapListModel res = MapListModel.fromJson(response.data);
      print(res.results.length);
      for (var i in res.results)
        DBProvider.db.createBusiness(
          BusinessModel(
            businessStatus: i.businessStatus,
            icon: i.icon,
            name: i.name,
            place_id: i.placeId,
            vicinity: i.vicinity,
            lat: i.geometry.location.lat,
            long: i.geometry.location.lng,
          ),
        );
    }
  }
}
