import 'package:flutter/material.dart';
import 'package:notes_app/helper/authenticate.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/helper/onboard_data.dart';

class OnBoardScreen extends StatefulWidget {
  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  List<OnBoardModel> slides = new List<OnBoardModel>();
  int currentIndex;
  PageController pageController = new PageController(initialPage: 0);

  @override
  void initState() {
    currentIndex = 0;
    slides = getSlides();
    super.initState();
  }

  Widget pageIndexIndicator(bool isCurrentPage) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      height: isCurrentPage ? 8.0 : 4.0,
      width: isCurrentPage ? 8.0 : 4.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCurrentPage ? Theme.of(context).primaryColor : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          controller: pageController,
          itemCount: slides.length,
          onPageChanged: (val) {
            setState(() {
              currentIndex = val;
            });
          },
          itemBuilder: (context, index) {
            return SliderTile(
              imagePath: slides[index].getimageAssetPath(),
              title: slides[index].getTitle(),
              desc: slides[index].getDesc(),
            );
          }),
      bottomSheet: currentIndex != slides.length - 1
          ? Container(
              height: 50.0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Text(
                        "Skip",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {
                        pageController.animateToPage(slides.length - 1,
                            duration: Duration(milliseconds: 50),
                            curve: Curves.linear);
                      },
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < slides.length; i++)
                          currentIndex == i
                              ? pageIndexIndicator(true)
                              : pageIndexIndicator(false),
                      ],
                    ),
                    InkWell(
                      child: Text(
                        "Next",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      onTap: () {
                        pageController.animateToPage(currentIndex + 1,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.linear);
                      },
                    ),
                  ],
                ),
              ),
            )
          : GestureDetector(
              onTap: () {
                HelperFunction.saveOnBoardpageViewInSharePreference(true);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => Authenticate()));
              },
              child: Container(
                alignment: Alignment.center,
                height: 60,
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).primaryColor,
                child: Text(
                  "Get Started",
                  style: TextStyle(color: Colors.white, fontSize: 22.0),
                ),
              ),
            ),
    );
  }
}

class SliderTile extends StatelessWidget {
  String imagePath;
  String title;
  String desc;

  SliderTile({this.imagePath, this.title, this.desc});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath),
            SizedBox(
              height: 12,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 14),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18,
              ),
            )
          ],
        ),
      ),
    );
  }
}
