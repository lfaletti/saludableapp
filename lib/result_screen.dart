import 'package:flutter/material.dart';
import 'nutrition_info.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends StatelessWidget {
  final List<NutritionInfo> nutritionInfoList;
  final String scannedText; // Added scannedText parameter

  ResultScreen({required this.nutritionInfoList, required this.scannedText}); // Updated constructor

  @override
  Widget build(BuildContext context) {
    if (nutritionInfoList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Resultados'),
        ),
                body: const Center(
          child: Text(
            'No se identificaron ingredientes. Inténtelo nuevamente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
          tooltip: 'Atrás',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados'),
      ),
      body: ListView.builder(
        itemCount: nutritionInfoList.length, // Add 1 for the extra card
        itemBuilder: (context, index) {
          if (index == nutritionInfoList.length) {
            // Render the extra card for scannedText
            /* return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text('Scanned Text'),
                subtitle: SelectableText(scannedText), // Make the text selectable
              ),
            ); */
          }

          Color cardColor;
          switch (nutritionInfoList[index].ratingLevel) {
            case 'good':
              cardColor = Color.fromARGB(255, 122, 207, 105);
              break;
            case 'warning':
              cardColor = Colors.yellow;
              break;
            case 'bad':
              cardColor = Colors.red;
              break;
            default:
              cardColor = Colors.white;
              break;
          }

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: cardColor, // Assign color based on rating level
            child: ListTile(
              title: Row(
                children: [
                  Text(nutritionInfoList[index].name),
                  if (nutritionInfoList[index].ratingLevel == 'warning')
                    Icon(
                      Icons.warning,
                      color: Colors.black,
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nutritionInfoList[index].description),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _launchGoogleSearch(nutritionInfoList[index].name);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(228, 75, 75, 75), // Set button background color to black
                      minimumSize: Size(120, 40), // Set minimum button size
                    ),
                    child: Text(
                      'Más información',
                      style: TextStyle(
                        color: Colors.grey[300], // Set button font color to light gray
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back),
        tooltip: 'Go back',
      ),
    );
  }

  void _launchGoogleSearch(String query) async {
    final url = 'https://www.google.com/search?q=$query';
    Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}