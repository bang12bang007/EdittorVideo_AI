import 'package:edit_video_app/assets/image.dart';
import 'package:edit_video_app/presentation/pages/view/page_select.dart';
import 'package:edit_video_app/presentation/widgets/util_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<String> trimmedVideos = [];
  bool isSeeking = false;

  @override
  void dispose() {
    _currentPage = 0;
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startAutoPageChange();
  }

  void _startAutoPageChange() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentPage = (_currentPage + 1) % 5;
            });
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
            _startAutoPageChange();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Padding(
          padding: const EdgeInsets.only(top: 0),
          child: SizedBox(
            height: 900,
            width: 600,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 5, // Số lượng ảnh
              itemBuilder: (context, index) {
                return Image.asset(
                  [
                    ImageUtils.loadingImg1,
                    ImageUtils.loadingImg2,
                    ImageUtils.loadingImg3,
                    ImageUtils.loadingImg4,
                    ImageUtils.loadingImg5,
                  ][index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 600,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: 20,
          child: SvgPicture.asset(
            ImageUtils.more,
            height: 18,
          ),
        ),
        Positioned(
          top: 80,
          left: 330,
          child: SvgPicture.asset(
            ImageUtils.pro,
            height: 25,
          ),
        ),
        Positioned(
          bottom: 80,
          left: 115,
          child: SizedBox(
            width: 180,
            height: 50,
            child: UtilButton(
                text: "New Project +",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SelectPage()),
                  );
                  null;
                },
                height: 40,
                borderRadius: 10),
          ),
        ),
      ]),
      // const SizedBox(height: 5),
    );
  }
}
