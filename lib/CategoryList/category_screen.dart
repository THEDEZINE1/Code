import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

import '../produtList/product_list_screen.dart';
import 'Category.dart';
import 'category_api.dart';

/*class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: FutureBuilder<List<Category>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView(
              children: snapshot.data!.map((category) => _buildCategoryTile(category)).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryTile(Category category) {
    return ExpansionTile(
      title: Text(category.name),
      leading: Image.network(
        category.icon,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/images/dummy_image.png', fit: BoxFit.cover, width: 50.0, height: 50.0);
        },
        fit: BoxFit.cover,
        width: 50.0,
        height: 50.0,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildSubCategoryList(category.subCategories, category.catID),
        ),
      ],
    );
  }

  Widget _buildSubCategoryList(List<SubCategory> subCategoryList, String categoryId) {
    return ListView.builder(
      shrinkWrap: true, // Ensures the ListView takes up only the space it needs
      physics: NeverScrollableScrollPhysics(), // Disable scrolling inside the ListView
      itemCount: subCategoryList.length,
      itemBuilder: (context, index) {
        final subCategory = subCategoryList[index];
        return _buildSubCategoryTile(subCategory, categoryId);
      },
    );
  }

  Widget _buildSubCategoryTile(SubCategory subCategory, String categoryId) {
    bool isExpanded = false; // Track the expansion state for each subcategory

    return StatefulBuilder(
      builder: (context, setState) {
        return Card(
          elevation: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                subCategory.icon,
                fit: BoxFit.cover,
                width: 50.0,
                height: 50.0,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/images/dummy_image.png', fit: BoxFit.cover, width: 50.0, height: 50.0);
                },
              ),
              SizedBox(height: 8.0),
              Text(subCategory.name, textAlign: TextAlign.center),
              IconButton(
                icon: Icon(isExpanded ? Icons.remove : Icons.add),
                onPressed: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
              ),
              // Print category ID when subcategory is clicked
              */ /*GestureDetector(
                onTap: () {
                  print('SubCategory clicked: Category ID = $categoryId, SubCategory ID = ${subCategory.catID}');
                },
                child: Text('Click to print SubCategory ID'),
              ),*/ /*
              if (isExpanded && subCategory.subSubCategories.isNotEmpty)
                _buildSubSubCategoryList(subCategory.subSubCategories, categoryId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubSubCategoryList(List<SubSubCategory> subSubCategoryList, String categoryId) {
    return Column(
      children: subSubCategoryList.map((subSubCategory) {
        return _buildSubSubCategoryTile(subSubCategory, categoryId);
      }).toList(),
    );
  }

  Widget _buildSubSubCategoryTile(SubSubCategory subSubCategory, String categoryId) {
    return GestureDetector(
      onTap: () {
        print('SubSubCategory clicked: Category ID = $categoryId, SubCategory ID = ${subSubCategory.catID}, SubSubCategory catID = ${subSubCategory.catID}');
      },
      child: ListTile(
        title: Text(subSubCategory.name),
        leading: Image.network(
          subSubCategory.icon,
          fit: BoxFit.cover,
          width: 30.0,
          height: 30.0,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/dummy_image.png', fit: BoxFit.cover, width: 30.0, height: 30.0);
          },
        ),
      ),
    );
  }
}*/

//new Design
class CategoryPage extends StatefulWidget {
  final String catID;

  CategoryPage({Key? key, required this.catID}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Category>> futureCategories;
  Category? selectedCategory; // Track the selected category
  String catId = '';
  int? _expandedSubCategoryIndex;
  String? _selectedCategoryId; // Track the selected category ID

  @override
  void initState() {
    super.initState();
    catId = widget.catID;

    futureCategories = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                'Categories',
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
      body: FutureBuilder<List<Category>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: AppColors.colorPrimary,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (selectedCategory == null && snapshot.data!.isNotEmpty) {
              selectedCategory = snapshot.data![0];
            }

            String catID = catId;
            List<Category> cateLists = snapshot.data!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              for (int i = 0; i < cateLists.length; i++) {
                if (cateLists[i].catID == catID) {
                  setState(() {
                    selectedCategory = cateLists[i];
                    catId = '';
                  });
                  break;
                }
              }
            });

            return Row(
              children: [
                Container(
                  width: 90.0,
                  color: AppTheme().mainBackgroundColor,
                  child: ListView(
                    children: snapshot.data!
                        .map((category) => _buildCategoryTile(category))
                        .toList(),
                  ),
                ),
                // Right side: Subcategory list (appears only when a category is selected)
                if (selectedCategory != null)
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme()
                            .whiteColor, // Change to any color you want as the background
                      ),
                      child: _buildSubCategoryList(
                        selectedCategory!.subCategories,
                        selectedCategory!.catID,
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return Center(
                child: Text(
              'No categories available.',
              style: CustomTextStyle.GraphikMedium(20, AppColors.black),
            ));
          }
        },
      ),
    );
  }

  Widget _buildCategoryTile(Category category) {
    return GestureDetector(
      onTap: () {
        if (category.hasSubCategory == false) {
          Get.to(ProductListScreen(
            onBack: () {},
            category: '${category.catID}',
            category_name: category.name,
          ));
          return; // Prevent `setState` if already navigating
        }

        setState(() {
          selectedCategory = selectedCategory == category ? null : category;
        });
      },
      child: Stack(
        children: [
          // Main category content
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            width: 90.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10.0),
                ClipOval(
                  child: Image.network(
                    category.icon,
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 50.0,
                      color: Colors.grey,
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.colorPrimary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.GraphikMedium(11, AppColors.black),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),

          if (selectedCategory == category)
            Positioned(
              right: 0,
              top: 15,
              bottom: 20,
              child: Container(
                width: 3.0,
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary, // Line color
                  borderRadius: BorderRadius.circular(180.0), // Rounded edges
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryList(
      List<SubCategory> subCategoryList, String categoryId) {
    if (_selectedCategoryId != categoryId) {
      _expandedSubCategoryIndex = null;
      _selectedCategoryId = categoryId;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            selectedCategory?.name ?? '', // Display selected category name
            overflow: TextOverflow.ellipsis,
            maxLines: 1, // Limit the text to 1 line
            style: CustomTextStyle.GraphikMedium(14, AppColors.black),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: subCategoryList.length,
            itemBuilder: (context, index) {
              final subCategory = subCategoryList[index];
              return _buildSubCategoryTile(subCategory, categoryId, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryTile(
      SubCategory subCategory, String categoryId, int index) {
    bool _isSubCategoryExpanded = _expandedSubCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {

          if (_isSubCategoryExpanded) {
            _expandedSubCategoryIndex = null; // Collapse if already expanded
          } else {
            _expandedSubCategoryIndex = index; // Expand the tapped subcategory
          }

          if (!subCategory.hasSubSubCategory) {
            Get.to(ProductListScreen(
              onBack: () {},
              category: subCategory.catID,
              category_name: subCategory.name,
            ));
          }
        });
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme().lineColor, // Border color
            width: 1.0, // Border width
          ),
          borderRadius:
              BorderRadius.circular(5.0), // Rounded corners (optional)
        ),
        child: Container(
          color: AppTheme().whiteColor,
          child: Column(
            children: [
              // Row for Image, Name and Expansion Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Image
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      subCategory.icon,
                      fit: BoxFit.fill,
                      width: 50.0,
                      height: 50.0,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/decont_splash_screen_images/decont_logo.png',
                          fit: BoxFit.fill,
                          width: 50.0,
                          height: 50.0,
                        );
                      },
                    ),
                  ),

                  // Center: Subcategory Name
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        subCategory.name,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1, // Limit the text to 1 line
                        style:
                            CustomTextStyle.GraphikRegular(13, AppColors.black),
                      ),
                    ),
                  ),

                  // Right side: Expansion Icon Button
                  subCategory.hasSubSubCategory
                      ? IconButton(
                          icon: Icon(
                            _isSubCategoryExpanded
                                ? Icons.remove
                                : Icons.add, // Toggle between + and - icons
                          ),
                          onPressed: () {
                            setState(() {
                              if (_isSubCategoryExpanded) {
                                _expandedSubCategoryIndex =
                                    null; // Collapse if already expanded
                              } else {
                                _expandedSubCategoryIndex =
                                    index; // Expand the tapped subcategory
                              }
                            });
                          }, // Action when the icon is pressed
                        )
                      : SizedBox(), // Empty widget if false
                ],
              ),

              if (_isSubCategoryExpanded &&
                  subCategory.subSubCategories.isNotEmpty)
                Divider(height: 5.0, color: AppTheme().lineColor),

              if (_isSubCategoryExpanded &&
                  subCategory.subSubCategories.isNotEmpty)
                _buildSubSubCategoryList(
                    subCategory.subSubCategories, categoryId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubSubCategoryList(
      List<SubSubCategory> subSubCategoryList, String categoryId) {
    return GridView.builder(
      // Set shrinkWrap to true to make the GridView only take as much space as needed
      shrinkWrap: true,
      padding: EdgeInsets.all(10.0),
      physics: NeverScrollableScrollPhysics(),
      // Disable scrolling on this GridView
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 200 / 250,
      ),
      itemCount: subSubCategoryList.length,
      itemBuilder: (context, index) {
        final subSubCategory = subSubCategoryList[index];
        return _buildSubSubCategoryTile(subSubCategory, categoryId);
      },
    );
  }

  // SubsubCategory Tile
  Widget _buildSubSubCategoryTile(
      SubSubCategory subSubCategory, String categoryId) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            // Print the catID and other details when clicked
            print('SubSubCategory clicked: ${subSubCategory.name}');
            //print('Category ID: $categoryId');

            print('Clicked on: ${subSubCategory.catID}');
            Get.to(
              ProductListScreen(
                onBack: () {},
                category: subSubCategory.catID,
                category_name: subSubCategory.name,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: AppColors.textFieldBorderColor,
                width: 1, // Border width
              ),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width < 600
                        ? MediaQuery.of(context).size.width *
                            0.45 // Small screens
                        : MediaQuery.of(context).size.width *
                            0.30, // Larger screens
                    height: MediaQuery.of(context).size.height < 500
                        ? MediaQuery.of(context).size.height *
                            0.20 // Short screens
                        : MediaQuery.of(context).size.height *
                            0.15, // Taller screens
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(5.0), // Adjust radius as needed
                      child: Image.network(
                        subSubCategory.icon,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/decont_splash_screen_images/decont_logo.png',
                            fit: BoxFit.fill,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    height:
                        MediaQuery.of(context).size.height * 0.01), // Spacing
                Text(
                  subSubCategory.name,
                  textAlign: TextAlign.center,
                  style: CustomTextStyle.GraphikRegular(12, AppColors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
