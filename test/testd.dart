import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class LocationComplete extends StatefulWidget {
  const LocationComplete({super.key});

  @override
  LocationCompleteState createState() => LocationCompleteState();
}

class LocationCompleteState extends State<LocationComplete> {
  final SearchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<dynamic> listofLocations = [];
  @override
  void initState() {
    SearchController.addListener((){
      _onchange();
    });
    super.initState();
    ;
  }
  _onchange(){placeSuggestion(SearchController.text);}
  
  void placeSuggestion(String input) async {
    const String apiKey = 'AIzaSyC66mA9H7RfpxJ8HgFhN6VbYUebEdBjIKk';
    try {
      String baseUrl = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          listofLocations = data['predictions'];
        });
      } else {
        throw Exception("Failed to load location suggestions");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Location Test",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
           ),
          ),
      
    ),
    body: Padding(padding: EdgeInsets.all(15),
    child: Column(
      children: [
        TextField(
          controller: SearchController,
          decoration: InputDecoration(
            hintText: "Search place..",
          ),
          onChanged: (value) {
            setState(){};
          },
          ),
          Visibility(
            visible: SearchController.text.isEmpty?false:true,
            child: Expanded(child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: listofLocations.length,
              itemBuilder: (context,index) {
              return GestureDetector(
                onTap: (){ },
                child: ListTile(title: Text(listofLocations[index]['description'],)),
              );
            }),
            ),
          ),
          Visibility(
            visible: SearchController.text.isEmpty?true:false,
            child: Container(margin: EdgeInsets.only(top: 20),child: ElevatedButton(onPressed: (){},child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.my_location,color: Colors.green,),
              SizedBox(width: 10,),
            Text("My Location",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color:Colors.green),)
            ],),),),
          ),
        ],
    ),
  ),
    );
  }
}

void testInternetConnection() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    if (response.statusCode == 200) {
      print("Internet connection is working.");
    } else {
      print("Failed to connect to the internet. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}