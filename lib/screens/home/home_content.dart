import 'package:app_news/screens/article/article_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Text("Video Recents",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,)),
          SizedBox(height: 10),
          CarouselSlider(
            items:[1,2,3,4,5].map((e) => Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(child: Text('Video $e', style: TextStyle(fontSize: 16.0, color: Colors.white),)),
            )).toList(),
            options: CarouselOptions(
              height: 200,
              )
              ),
          const ArticlePage(),
        ],
      ),
    );
  }
}

