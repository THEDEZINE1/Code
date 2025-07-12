import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'CustomeTextStyle/custometextstyle.dart';

class ImageViewScreen extends StatefulWidget {
  final int initialIndex;
  final List<String> galleryItems;
  final String productName;

  ImageViewScreen(
      {required this.initialIndex,
      required this.galleryItems,
      required this.productName});

  @override
  _ImageViewScreenState createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          kToolbarHeight + 1.0,
        ),
        child: Column(
          children: [
            AppBar(
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  );
                },
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
              title: Text(
                widget.productName,
                //widget.carName, // Use widget.carName here
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
      body: Column(
        children: [
          Expanded(
            child: PhotoViewGallery.builder(
              itemCount: widget.galleryItems.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.galleryItems[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered,
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: BoxDecoration(
                  color: AppTheme().mainBackgroundColor), // Background color
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Container(
            height: 60, // Thumbnail container height
            color: AppTheme()
                .mainBackgroundColor, // Background color for thumbnails
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.galleryItems.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index
                            ? AppColors.colorPrimary
                            : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.galleryItems[index],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                        color: AppColors.colorPrimary,
                      )),
                      errorWidget: (context, error, stackTrace) {
                        // In case of error, show a default image
                        return Image.asset(
                          'assets/decont_splash_screen_images/decont_logo.png',
                          fit: BoxFit.contain,
                          height: 100,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
