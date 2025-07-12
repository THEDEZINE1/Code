import 'package:flutter/material.dart';
import '../CustomeTextStyle/custometextstyle.dart';
import '../theme/AppTheme.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewScreenNotification extends StatefulWidget {
  final int initialIndex;
  final List<String> galleryItems;

  String? productAppbarTitle;

  ImageViewScreenNotification(
      {required this.initialIndex,
      required this.galleryItems,
      required this.productAppbarTitle});

  @override
  ImageViewScreenNotificationState createState() =>
      ImageViewScreenNotificationState();
}

class ImageViewScreenNotificationState
    extends State<ImageViewScreenNotification> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          kToolbarHeight + 1.0, // AppBar height + bottom border
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: AppColors.colorPrimary,
              elevation: 0.0,
              leading: Builder(
                builder: (BuildContext context) {
                  return RotatedBox(
                    quarterTurns: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppTheme().whiteColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
              title: Text(
                widget.productAppbarTitle.toString(),
                style: CustomTextStyle.GraphikMedium(16, AppTheme().whiteColor),
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

          widget.galleryItems.isEmpty
              ? const SizedBox(
                  height: 300,
                )
              : Expanded(
                  child: PhotoViewGallery.builder(
                    itemCount: widget.galleryItems.length,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions.customChild(
                        child: Image.network(
                          widget.galleryItems[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              SizedBox(
                            height: 300,
                            child: Image.asset(
                              'assets/decont_splash_screen_images/decont_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered,
                      );
                    },
                    scrollPhysics: const BouncingScrollPhysics(),
                    backgroundDecoration: BoxDecoration(
                      color: AppTheme().whiteColor,
                    ),
                    pageController: _pageController,
                    onPageChanged: (index) {
                      setState(() {});
                    },
                  ),
                ),

          /// ✅ Thumbnails section
          Container(
            height: 70,
            color: AppTheme().whiteColor,
            child: widget.galleryItems.isEmpty
                ? const SizedBox()
                : ListView.builder(
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: AppTheme().primaryColor,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              widget.galleryItems[index],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, url, error) => SizedBox(
                                height: 150,
                                child: Image.asset(
                                  'assets/decont_splash_screen_images/decont_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
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
