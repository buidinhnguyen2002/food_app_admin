import 'dart:convert';
import 'dart:io';

import 'package:final_project_admin/models/food.dart';
import 'package:final_project_admin/models/restaurant.dart';
import 'package:final_project_admin/providers/food_data.dart';
import 'package:final_project_admin/providers/restaurant_provider.dart';
import 'package:final_project_admin/utils/api_constants.dart';
import 'package:final_project_admin/utils/functions.dart';
import 'package:final_project_admin/utils/widget.dart';
import 'package:final_project_admin/widget/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Food food;
  File? _image;
  final picker = ImagePicker();
  Future choiseImage() async {
    var pickerImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      print("DAY NEFFFFFF");
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
      await updateFood(imagePath);
    } else {
      print('Image not update');
    }
  }

  Future updateFood(String imagePath) async {
    final Map<String, dynamic> foodData = {
      'id': foodId,
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
    print(_foodNameController.text);
    print(foodId);
    final http.Response response = await http.put(
      Uri.parse(API.getAllFoods),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(foodData),
    );

    if (response.statusCode == 200) {
      try {
        await showNotificationAndCloseBottomSheet(
            context, "Cập nhật thành công!");
      } catch (e) {
        print("Error in showNotification: $e");
      }
      print('Food Created Successfully');
    } else {
      print('Failed to create food. Error: ${response.reasonPhrase}');
    }
  }

  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _idRestaurantController = TextEditingController();
  var restaurantId;
  var foodId;
  List<Restaurant> restaurants = [];
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final id = args!['id'];
      restaurants =
          Provider.of<RestaurantProvider>(context, listen: false).restaurants;
      food = Provider.of<FoodData>(context, listen: false).getFoodById(id);
      setState(() {
        foodId = id;
        _foodNameController.text = food.foodName;
        _priceController.text = food.price.toInt().toString();
        _descriptionController.text = food.description;
        _quantityController.text = food.quantityAvailable.toString();
        _idRestaurantController.text = food.restaurantId;
        restaurantId = food.restaurantId;
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _foodNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _idRestaurantController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(food.foodName),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: device.height - 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _image == null
                        ? Image.network(
                            food.imageSource,
                            fit: BoxFit.cover,
                          )
                        : Image.file(_image!, fit: BoxFit.cover),
                    Positioned(
                      right: 10,
                      child: IconButton.filled(
                        onPressed: choiseImage,
                        icon: const Icon(Icons.edit),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: customInput(
                                      _foodNameController,
                                      context,
                                      "Food name",
                                      "Enter the food name",
                                      TextInputType.text),
                                ),
                                BoxEmpty.sizeBox10,
                                Expanded(
                                  flex: 1,
                                  child: customInput(
                                      _priceController,
                                      context,
                                      'Price',
                                      'Enter the price',
                                      TextInputType.number,
                                      suffixText: 'VNĐ'),
                                ),
                              ],
                            ),
                            BoxEmpty.sizeBox20,
                            customInput(
                                _descriptionController,
                                context,
                                'Description',
                                'Enter the description',
                                TextInputType.text),
                            BoxEmpty.sizeBox20,
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: customInput(
                                      _quantityController,
                                      context,
                                      'Quantity',
                                      'Enter the quantity food',
                                      TextInputType.number),
                                ),
                                BoxEmpty.sizeBox15,
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding:
                                        const EdgeInsetsDirectional.symmetric(
                                            horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground),
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
                          ],
                        ),
                      ),
                      BoxEmpty.sizeBox5,
                      CommonButton(title: "Update", onPress: uploadImage),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
