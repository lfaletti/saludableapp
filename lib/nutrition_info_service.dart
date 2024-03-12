import 'nutrition_info.dart';
import 'definitions_service.dart';
import 'package:diacritic/diacritic.dart';

// This service process the extracted text for each term getting a definition

class NutritionInfoService {
  Future<List<NutritionInfo>> processText(String extractedText) async {
    List<NutritionInfo> nutritionInfoList = [];

    var definitionService = DefinitionService();

    List<String> definitionNames = await definitionService.getAllNames();    

    for (String definitionName in definitionNames) {      
      String normalizedDefinitionName = removeDiacritics(definitionName.toLowerCase());
      String normalizedExtractedText = removeDiacritics(extractedText.toLowerCase());

      //print(normalizedDefinitionName);
      // print(normalizedExtractedText);

      if (normalizedExtractedText.contains(normalizedDefinitionName)) {
        NutritionInfo? definition = await definitionService.getDefinition(definitionName);

        if (definition != null && !nutritionInfoList.any((info) => info.name == definition.name)) {
          nutritionInfoList.add(definition);
        }
      }
    }

    return nutritionInfoList;
  }
}
