import 'dart:async';

import 'package:db/db/dbProvider.dart';
import 'package:db/model/businessModel.dart';
import 'package:db/netwrok/api.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _isLoading = false;
  var _mapLoading = true;
  List<BusinessModel> _businessList;

  /// Set of displayed markers and cluster markers on the map
  List<Marker> _markers = <Marker>[];

  /// marker coordinates
  Completer<GoogleMapController> _controller = Completer();

  TextEditingController _searchQuery = TextEditingController();
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    _loadFromApi();
    setCustomMapPin();
    super.initState();
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/pin.png');
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    _businessList = await DBProvider.db.getAllBusiness();
    print("len ${_businessList[0].lat} ${_businessList[0].long}");
    _updateMarker(_businessList);
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _buildMapView(),
      ),
    );
  }

  _loadFromApi() async {
    setState(() {
      _isLoading = true;
    });

    var apiProvider = ApiProvider();
    await apiProvider.getAllBusiness();
    if (mounted)
      setState(() {
        _isLoading = false;
      });
  }

  _updateMarker(_businessList) {
    List<Marker> markers = [];

    print("_updateMarker list length ${_businessList.length}");
    try {
      for (var e in _businessList) {
        markers.add(
          Marker(
            position: LatLng(
              e.lat,
              e.long,
            ),
            icon: pinLocationIcon,
            infoWindow: InfoWindow(
              title: e.name,
            ),
            onTap: () {
              _launchMapsUrl(
                e.lat,
                e.long,
              );
            },
            markerId: MarkerId(DateTime.now().toString()),
          ),
        );
      }
      setState(() {
        _markers = markers;
        print("OK ${_markers.length}");
      });

      if (mounted)
        setState(() {
          _mapLoading = false;
        });
    } catch (e, st) {
      print(e);
      print(st);
    }
  }

  Widget _buildMapView() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            children: <Widget>[
              getSearchView(),
              Expanded(
                child: _isLoading ? Center(child: CircularProgressIndicator()) : getMapView(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void performSearch(String query) async {
    if (_searchQuery.text.trim().isEmpty) return;
    if (mounted)
      setState(() {
        _mapLoading = true;
      });

    if (_searchQuery.text.isNotEmpty) {
      var list = _businessList
          .where((element) => element.name.toLowerCase().contains(_searchQuery.text.toLowerCase()));
      _updateMarker(list);
    }
  }

  void setOldData(String query) {
    if (_searchQuery.text.isEmpty) {
      if (mounted)
        setState(() {
          _isLoading = false;
        });

      //Hide Keyboard
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  Widget getSearchView() {
    return Column(
      children: <Widget>[
        TextField(
          controller: _searchQuery,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onSubmitted: performSearch,
          onChanged: setOldData,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Search using business name",
            prefixIcon: Icon(
              Icons.search,
              size: 18.0,
            ),
          ),
          style: TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }

  Widget getMapView() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: _mapLoading ? 0 : 1,
          child: GoogleMap(
            myLocationEnabled: false,
            compassEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(23.0225, 72.5714),
              zoom: 12.0,
            ),
            markers: Set<Marker>.of(_markers),
            onMapCreated: (controller) => _onMapCreated(controller),
            onCameraMove: (position) => {},
          ),
        ),

        // Map loading indicator
        Opacity(
          opacity: _mapLoading ? 1 : 0,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  _launchMapsUrl(latitude, longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
