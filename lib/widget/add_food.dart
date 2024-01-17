import 'dart:convert';
import 'dart:io';

import 'package:final_project_admin/models/restaurant.dart';
import 'package:final_project_admin/providers/restaurant_provider.dart';
import 'package:final_project_admin/utils/api_constants.dart';
import 'package:final_project_admin/utils/functions.dart';
import 'package:final_project_admin/utils/widget.dart';
import 'package:final_project_admin/widget/common_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AddFoodModalBottomSheet extends StatefulWidget {
  const AddFoodModalBottomSheet({super.key});

  @override
  State<AddFoodModalBottomSheet> createState() =>
      _AddFoodModalBottomSheetState();
}

class _AddFoodModalBottomSheetState extends State<AddFoodModalBottomSheet> {
  File? _image;
  final picker = ImagePicker();
  late BuildContext localContext;
  Future choseImage() async {
    var pickerImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickerImage!.path);
    });
  }

  Future uploadImage() async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(API.upload),
    );
    request.fields['name'] = _foodNameController.text;
    var pic = await http.MultipartFile.fromPath("image", _image!.path);
    request.files.add(pic);
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var responseData = json.decode(responseBody);
      var imagePath = responseData['image_path'];
      print("RESPONSEEEEEEEEEEEEE $imagePath");
      print('Image Uploaded');
      await createFood(_foodNameController.text, imagePath);
    } else {
      print('Image not update');
    }
  }

  Future createFood(String foodName, String imagePath) async {
    final Map<String, dynamic> foodData = {
      'food_name': _foodNameController.text,
      'restaurant_id': restaurantId,
      'description': _descriptionController.text,
      'price': _priceController.text,
      'unit': 'VNĐ',
      'rate': 5,
      'image_source': imagePath,
      'quantity_init': _quantityController.text,
      'quantity_available': _quantityController.text,
    };

    final http.Response response = await http.post(
      Uri.parse(API.getAllFoods),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(foodData),
    );

    if (response.statusCode == 200) {
      try {
        await showNotificationAndCloseBottomSheet(
            localContext, "Thêm món ăn thành công!");
      } catch (e) {
        print("Error in showNotification: $e");
      }
      print('Food Created Successfully');
    } else {
      print('Failed to create food. Error: ${response.reasonPhrase}');
    }
  }

  List<Restaurant> restaurants = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      restaurants =
          Provider.of<RestaurantProvider>(context, listen: false).restaurants;
    });
  }

  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  var restaurantId = "1";
  @override
  Widget build(BuildContext context) {
    localContext = context;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        color: Theme.of(context).colorScheme.background,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: customInput(_foodNameController, context, "Food name",
                      "Enter the food name", TextInputType.text),
                ),
                BoxEmpty.sizeBox10,
                Expanded(
                  flex: 1,
                  child: customInput(_priceController, context, 'Price',
                      'Enter the price', TextInputType.number,
                      suffixText: 'VNĐ'),
                ),
              ],
            ),
            BoxEmpty.sizeBox10,
            customInput(_descriptionController, context, 'Description',
                'Enter the description', TextInputType.text),
            BoxEmpty.sizeBox10,
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: customInput(_quantityController, context, 'Quantity',
                      'Enter the quantity food', TextInputType.number),
                ),
                BoxEmpty.sizeBox15,
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onBackground),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton<String>(
                      borderRadius: BorderRadius.circular(20),
                      isDense: true,
                      value: restaurantId,
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      onChanged: (newValue) {
                        setState(() {
                          restaurantId = newValue!;
                        });
                      },
                      items: [
                        for (Restaurant res in restaurants)
                          DropdownMenuItem(
                            value: res.id,
                            child: Text(
                              '#${res.id} - ${res.name}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            BoxEmpty.sizeBox10,
            OutlinedButton.icon(
              onPressed: choseImage,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text("Upload image"),
            ),
            BoxEmpty.sizeBox10,
            Expanded(
              child: _image == null
                  ? const SizedBox()
                  : Image.file(
                      _image!,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
            ),
            BoxEmpty.sizeBox5,
            CommonButton(
              title: "Create",
              onPress: () async {
                await uploadImage();
              },
              paddingVertical: 12,
            ),
          ],
        ),
      ),
    );
  }
}
