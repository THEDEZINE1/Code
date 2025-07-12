import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../BaseUrl.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

String? user_token = '';
String? userID = '';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  bool isLoading = false;
  bool hasMoreData = true;
  List<Address> _addresses = [];

  late String _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

    _selectedAddressId = _addresses.isNotEmpty ? _addresses.first.id : '';
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_token = prefs.getString('user_token') ?? '';
      userID = prefs.getString('userID') ?? '';
    });
    await _dashboardData();
  }

  Future<void> _dashboardData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'view': 'addresses',
      'page': 'list',
      'custID': '$userID',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');
        if (data['status'] == 'success' && data['result'] == 1) {
          List<dynamic> addressData = data['data']['address_list'] ?? [];
          setState(() {
            _addresses.clear();
            _addresses.addAll(
                addressData.map((json) => Address.fromJson(json)).toList());
            _selectedAddressId =
                _addresses.isNotEmpty ? _addresses.first.id : '';
          });
        } else {
          _showErrorSnackBar('No addresses found');
        }
      } else {
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.white)),
      ),
    );
  }

  Future<void> _loadLanguage(String langCode) async {
    final String jsonString =
        await rootBundle.loadString('assets/lang/$langCode.json');
    setState(() {
      localizedStrings = Map<String, String>.from(json.decode(jsonString));
    });
  }

  Future<void> _loadCurrentLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('selected_language_code');

    if (langCode != null && langCode.isNotEmpty) {
      setState(() {
        currentLangCode = langCode;
      });
      await _loadLanguage(currentLangCode);
    }
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  // Function to remove address from the list
  Future<void> _removeAddress(String id) async {
    // Call the API to delete the address
    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'view': 'addresses',
      'page': 'remove',
      'custID': '$userID',
      'caddressID': id,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body.trim());
        // Check if the API call was successful

        if (responseData['status'] == 'success' &&
            responseData['result'] == 1) {
          setState(() {
            // Remove the address from the local list
            _addresses.removeWhere((address) => address.id == id);

            // Update the selected address ID
            if (_selectedAddressId == id && _addresses.isNotEmpty) {
              _selectedAddressId = _addresses.first.id;
            } else if (_addresses.isEmpty) {
              _selectedAddressId = '';
            }
          });

          log('$responseData');
        } else {
          // Handle the error case from the API
          _showErrorSnackBar('Error: ${responseData['message']}');
        }
      } else {
        // Handle the case when the response status is not 200
        _showErrorSnackBar(
            'Failed to delete address: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to edit an address
  void _editAddress(Address address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNewAddress(address: address),
      ),
    );

    if (result != null && result is Address) {
      setState(() {
        // Find the address by id and update it
        final index = _addresses.indexWhere((a) => a.id == result.id);
        if (index != -1) {
          _addresses[index] = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 1.0, // AppBar default height + container height
        ),
        child: Column(
          children: [
            AppBar(
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (BuildContext context) {
                  return RotatedBox(
                    quarterTurns: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Address',
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
            ),
            Container(
              height: 1.0,
              color: AppTheme().lineColor,
            ),
          ],
        ),
      ),
      backgroundColor: AppTheme().mainBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppTheme().whiteColor,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddNewAddress(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme().whiteColor,
                          surfaceTintColor: AppTheme().whiteColor,
                          foregroundColor: AppTheme().whiteColor,
                          side: const BorderSide(
                              color: AppColors.colorPrimary, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(translate('Add New Address'),
                            style: CustomTextStyle.GraphikMedium(
                                16, AppColors.black)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? CircularProgressIndicator(
                    color: AppColors.colorPrimary,
                  )
                : Container(
                    color: AppColors.mainBackgroundColor,
                    child: SizedBox(
                      child: Container(
                        color: AppColors.white,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _addresses.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                AddressCard(
                                  address: _addresses[index],
                                  selectedAddressId: _selectedAddressId,
                                  onSelected: (String? value) {
                                    setState(() {
                                      _selectedAddressId = value ?? '';
                                    });
                                  },
                                  onEdit: _editAddress,
                                  onDelete: _removeAddress,
                                ),
                                if (index != _addresses.length - 1)
                                  Divider(color: AppTheme().lineColor),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final String? selectedAddressId;
  final ValueChanged<String?> onSelected;
  final Function(String) onDelete;
  final Function(Address) onEdit;

  const AddressCard({
    Key? key,
    required this.address,
    required this.selectedAddressId,
    required this.onSelected,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onSelected(address.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: address.id,
              groupValue: selectedAddressId,
              onChanged: onSelected,
              activeColor: AppColors.colorPrimary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  address.company == ''
                      ? const SizedBox.shrink()
                      : const SizedBox(height: 10.0),
                  address.company == ''
                      ? const SizedBox.shrink()
                      : Text(
                          address.company,
                          style: CustomTextStyle.GraphikMedium(
                              14, AppColors.black),
                        ),
                  const SizedBox(height: 8.0),
                  Text(
                    address.first_name,
                    style: CustomTextStyle.GraphikMedium(14, AppColors.black),
                  ),
                  const SizedBox(height: 8.0),
                  Visibility(
                    visible: address
                        .address_1.isNotEmpty, // Check if address is not empty
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/location_pin.svg',
                          height: 18.0,
                          width: 18.0,
                          color: AppTheme().secondTextColor,
                        ),
                        const SizedBox(
                            width: 8.0), // Spacing between icon and text
                        Expanded(
                          // Wrap the Text widget in Expanded
                          child: Text(
                            '${address.address_1}, ${address.address_2}, ${address.area}, ${address.city}, ${address.state}, ${address.pincode}',
                            style: CustomTextStyle.GraphikMedium(
                                14, AppColors.black),
                            maxLines: 2, // Limit to 2 lines for address
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8.0),
                  Visibility(
                    visible:
                        address.phone.isNotEmpty, // Check if phone is not empty
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/phone.svg', // Path to your SVG icon
                          height: 18.0, // Adjust height as needed
                          width: 18.0, // Adjust width as needed
                          color: AppTheme().secondTextColor,
                        ),
                        const SizedBox(
                            width: 8.0), // Spacing between icon and text
                        Text(
                          '${address.phone}',
                          style: CustomTextStyle.GraphikMedium(
                              14, AppColors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Visibility(
                    visible:
                        address.gst.isNotEmpty, // Check if phone is not empty
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/gst_icon.svg', // Path to your SVG icon
                          height: 18.0, // Adjust height as needed
                          width: 18.0, // Adjust width as needed
                          color: AppTheme().secondTextColor,
                        ),
                        const SizedBox(
                            width: 8.0), // Spacing between icon and text
                        Text('${address.gst}',
                            style: CustomTextStyle.GraphikMedium(
                                14, AppColors.black)),
                      ],
                    ),
                  ),
                  //Text('GST: ${address.gst}'),
                  const SizedBox(height: 15.0),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          onEdit(address);
                        },
                        child: Text('Edit',
                            style: CustomTextStyle.GraphikMedium(
                                15, AppColors.botIconColor)),
                      ),
                      const SizedBox(width: 15.0),
                      GestureDetector(
                        onTap: () {
                          onDelete(address.id);
                        },
                        child: Text('Delete',
                            style: CustomTextStyle.GraphikMedium(
                                15, AppColors.red)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Address {
  final String id;
  final String company;
  final String first_name;
  final String area;
  final String address_1;
  final String address_2;
  final String city;
  final String state;
  final String pincode;
  final String email;
  final String phone;
  final String gst;

  Address({
    required this.id,
    required this.company,
    required this.first_name,
    required this.area,
    required this.address_1,
    required this.address_2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.email,
    required this.phone,
    required this.gst,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['addID'],
      company: json['company_name'],
      first_name: json['name'],
      address_1: json['address1'],
      address_2: json['address2'],
      area: json['area'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      email: json['email'],
      phone: json['phone'],
      gst: json['gst'] ?? '',
    );
  }
}

class AddNewAddress extends StatefulWidget {
  final Address? address;

  const AddNewAddress({Key? key, this.address}) : super(key: key);

  @override
  State<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _AreaNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address_1_Controller = TextEditingController();
  final _address_2_Controller = TextEditingController();
  final _pincodeController = TextEditingController();
  final _cityController = TextEditingController();

  final _gstController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  //int? stateID;
  String? stateID;

  Map<String, String> localizedStrings = {};
  String currentLangCode = 'en';
  String addressId = '';
  bool isLoading = false;
  bool hasMoreData = true;
  List<Map<String, dynamic>> _stateList = []; // To store state data

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguagePreference();
    _initializeData();

    if (widget.address != null) {
      _companyController.text = widget.address!.company;
      addressId = widget.address!.id;
      _firstNameController.text = widget.address!.first_name;
      _emailController.text = widget.address!.email;
      _address_1_Controller.text = widget.address!.address_1;
      _address_2_Controller.text = widget.address!.address_2;
      _AreaNameController.text = widget.address!.area;
      _pincodeController.text = widget.address!.pincode;
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state;
      _phoneController.text = widget.address!.phone;
      _gstController.text = widget.address!.gst;
    }
  }

  Future<void> _initializeData() async {
    // Load user preferences and initialize data
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user_token = prefs.getString('user_token') ?? '';
    });
    await _dashboardData();
  }

  Future<void> _dashboardData() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(baseUrl);

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $user_token',
    };

    final Map<String, dynamic> body = {
      'view': 'state',
      'page': 'list',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body.trim());
        log('Response data: $data');

        setState(() {
          //_stateList = List<Map<String, dynamic>>.from(data['data']['state_list']);
          _stateList = List<Map<String, dynamic>>.from(data['data']);
        });

        // Check if the _stateController has a value matching any state's name
        final stateName = _stateController.text;
        final matchedState = _stateList.firstWhere(
          (state) => state['name'].toString() == stateName,
          orElse: () => {}, // Default to null if no match is found
        );

        // Set stateID if a match is found
        stateID = matchedState['name']
            .toString(); // Ensure to convert id to String if needed
        log('Matched State: $stateName, StateID: $stateID');
      } else {
        _showErrorSnackBar('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .copyWith(color: AppColors.white))),
    );
  }

  Future<void> _loadLanguage(String langCode) async {
    final String jsonString =
        await rootBundle.loadString('assets/lang/$langCode.json');
    setState(() {
      localizedStrings = Map<String, String>.from(json.decode(jsonString));
    });
  }

  Future<void> _loadCurrentLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? langCode = prefs.getString('selected_language_code');

    if (langCode != null && langCode.isNotEmpty) {
      setState(() {
        currentLangCode = langCode;
      });
      await _loadLanguage(currentLangCode);
    }
  }

  String translate(String key) {
    return localizedStrings[key] ?? key;
  }

  void _showEmailOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme().whiteColor,
          surfaceTintColor: AppTheme().whiteColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select State',
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _stateList.length,
              itemBuilder: (context, index) {
                final stateId = _stateList[index]['name'].toString();
                final stateName =
                    getStateNameById(stateId.toString()); // Get the name by ID

                return ListTile(
                  title: Text(stateName,
                      style: CustomTextStyle.GraphikRegular(
                          14, AppColors.secondTextColor)), // Display state name
                  onTap: () {
                    setState(() {
                      _stateController.text = stateName;
                      stateID = stateId;
                    });
                    log('$stateID');
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  String getStateNameById(String id) {
    try {
      final state =
          _stateList.firstWhere((element) => element['name'].toString() == id);
      return state['name'];
    } catch (e) {
      return 'Unknown State'; // Fallback in case the ID is not found
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _firstNameController.dispose();
    _AreaNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _address_1_Controller.dispose();
    _address_2_Controller.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 1.0, // AppBar default height + container height
        ),
        child: Column(
          children: [
            AppBar(
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (BuildContext context) {
                  return RotatedBox(
                    quarterTurns: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                widget.address == null
                    ? translate('Add New Address')
                    : 'Edit Address',
                style: CustomTextStyle.GraphikMedium(16, AppColors.black),
              ),
            ),
            Container(
              height: 1.0,
              color: AppTheme().lineColor,
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: translate('First Name'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: translate('Email ID'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: translate('Mobile number'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _address_1_Controller,
                        decoration: InputDecoration(
                          labelText: translate('House no./ Building Name'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _address_2_Controller,
                        decoration: InputDecoration(
                          labelText: translate('Road Name/ Colony'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _AreaNameController,
                        decoration: InputDecoration(
                          labelText: translate('Area Name'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: InputDecoration(
                          labelText: translate('PIN Code'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: translate('City'),
                                labelStyle: CustomTextStyle.GraphikMedium(
                                    14, AppColors.greyColor),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.textFieldBorderColor)),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.textFieldBorderColor,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.textFieldBorderColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: CustomTextStyle.GraphikRegular(
                                  14, AppColors.black),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              autofocus: false,
                              showCursor: false,
                              controller: _stateController,
                              onTap: _showEmailOptionsDialog,
                              // Show dialog on tap
                              enableInteractiveSelection: false,
                              // Disable text selection and cursor
                              decoration: InputDecoration(
                                labelText: translate('State'),
                                labelStyle: CustomTextStyle.GraphikMedium(
                                    14, AppColors.greyColor),
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.textFieldBorderColor)),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.textFieldBorderColor,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.textFieldBorderColor,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              style: CustomTextStyle.GraphikRegular(
                                  14, AppColors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _companyController,
                        /*validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a company name';
                          }
                          return null;
                        },*/

                        //controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: translate('Company Name'),
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _gstController,
                        /*validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a GST number';
                          }
                          return null;
                        },*/
                        decoration: InputDecoration(
                          labelText: 'GST No.',
                          labelStyle: CustomTextStyle.GraphikMedium(
                              14, AppColors.greyColor),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: AppColors.textFieldBorderColor)),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldBorderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style:
                            CustomTextStyle.GraphikRegular(14, AppColors.black),
                      ),
                      const SizedBox(height: 15.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: SizedBox(
                width: double.infinity, // Make button full width
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newAddress = Address(
                        id: addressId,
                        company: _companyController.text,
                        first_name: _firstNameController.text,
                        area: _AreaNameController.text,
                        address_1: _address_1_Controller.text,
                        address_2: _address_2_Controller.text,
                        phone: _phoneController.text,
                        gst: _gstController.text,
                        city: _cityController.text,
                        state: _stateController.text,
                        pincode: _pincodeController.text,
                        email: _emailController.text,
                      );

                      // Send the POST request

                      final url =
                          Uri.parse(baseUrl); // Replace with your API endpoint
                      final headers = {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Authorization': 'Bearer $user_token',
                      };
                      final body = {
                        'view': 'addresses',
                        'custID': userID ?? '',
                        'page': 'add',
                        'caddressID': addressId,
                        'ccompany': newAddress.company,
                        'cname': newAddress.first_name,
                        'caddress1': newAddress.address_1,
                        'caddress2': newAddress.address_2,
                        'carea': newAddress.area,
                        'cphone': newAddress.phone,
                        'cgst': newAddress.gst,
                        'ccity': newAddress.city,
                        'cstate': stateID,
                        'cpincode': newAddress.pincode,
                        'cemail': newAddress.email,
                      };

                      try {
                        final response =
                            await http.post(url, headers: headers, body: body);

                        if (response.statusCode == 200) {
                          // Successfully added the address
                          final responseData = jsonDecode(response.body.trim());

                          // Check for success status in the response
                          if (responseData['status'] == 'success' &&
                              responseData['result'] == 1) {
                            // Successfully added the address
                            log('Data Inserted successfully: ${responseData['message']}');
                            // Optionally, show a snackbar or dialog for success

                            Navigator.pop(context,
                                newAddress); // Return to the previous screen
                            Navigator.popAndPushNamed(
                                context, '/add_edit_address');
                          } else {
                            // Handle the error case (status is not 'success')
                            log('Failed to add address: ${responseData['message']}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error: ${responseData['message']},',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayMedium!
                                          .copyWith(color: AppColors.white))),
                            );
                          }
                        } else {
                          log('Failed to add address. Status code: ${response.statusCode}');
                          log('Error: ${response.body}');
                        }
                      } catch (error) {
                        log('Error occurred while adding address: $error');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPrimary,
                    // Background color of the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          5), // Rounded corners with radius
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 15), // Vertical padding for button content
                  ),
                  child: Text(
                      widget.address == null
                          ? translate('Add Address')
                          : translate('Save Address'),
                      style:
                          CustomTextStyle.GraphikMedium(16, AppColors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
