import 'dart:async';
import 'dart:math';

import 'package:artiq/data.dart';
import 'package:artiq/page/contentPage.dart';
import 'package:artiq/page/postPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class Func {
  static Fetch fetch = new Fetch();
  static Future<List<Guide>> futureGuideList = fetch.fetchGuide();
  static Future<List<Post>> futureData = fetch.fetchPost('music');
  static double _categoryPage = 0;

  static Future<List<Guide>> getGuideList() {
    return futureGuideList;
  }

  static Future<List<Post>> getPostList() {
    return futureData;
  }

  static void refreshInit() {
    if (ArtiqData.refreshTimer != null) {
      ArtiqData.refreshTimer.cancel();
    }

    ArtiqData.refreshSec = 0;
    ArtiqData.refreshColor = Colors.black;
  }

  static void refreshPost(BuildContext context, PageController _pageController) async {
    ArtiqData.refreshColor = Colors.red;
    ArtiqData.refreshSec = ArtiqData.refreshPerSec;

    ArtiqData.emptyFutureMap(ArtiqData.category);
    Func.futureData = fetch.fetchPost(ArtiqData.category);

    _pageController.jumpToPage(0);
  }

  static Post getRandomPost(String category, Post post) {
    List<Post> postList = ArtiqData.getPostList(category);

    var random = new Random();
    var ran = random.nextInt(postList.length);
    var now = postList.indexOf(post);

    while (ran == now) {
      ran = random.nextInt(postList.length);

      if (ran < 0 || ran >= postList.length) {
        break;
      }
    }

    return postList[ran];
  }

  static Post getBeforePost(String category, Post post) {
    List<Post> postList = ArtiqData.getPostList(category);

    int bef = postList.indexOf(post) - 1;
    if (bef < 0) {
      bef = postList.length - 1;
    }

    return postList[bef];
  }

  static Post getNextPost(String category, Post post) {
    List<Post> postList = ArtiqData.getPostList(category);

    int next = postList.indexOf(post) + 1;
    if (next >= postList.length) {
      next = 0;
    }

    return postList[next];
  }

  static void setData(String category, int categoryIdx) {
    ArtiqData.category = category;
    ArtiqData.categoryIdx = categoryIdx;
    Func.futureData = fetch.fetchPost(category);
  }

  static void setCategoryPage(double categoryPage) {
    Func._categoryPage = categoryPage;
  }

  static void categoryTab(PageController _categoryController, String category, int categoryIdx) {
    setData(category, categoryIdx);
    _categoryController.jumpToPage(categoryIdx);
  }

  static void goPostPage(BuildContext context) {
    Func.refreshInit();

    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) {
              return PostPage();
            },
            settings: RouteSettings(name: PostPage.routeName)));
  }

  static void goContentPage(BuildContext context, Post post) {
    Func.refreshInit();

    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) {
              return ContentPage(post);
            },
            settings: RouteSettings(name: ContentPage.routeName)));
  }

  static void goPage(BuildContext context, String routeName) {
    Func.refreshInit();

    Navigator.pushNamed(context, routeName);
  }

  static void goPageRemove(BuildContext context, String routeName) {
    Func.refreshInit();

    Navigator.pushNamedAndRemoveUntil(context, routeName, (_) => false);
  }

  static InkWell getCategory(PageController _categoryController, String category, String title, int idx) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        if (ArtiqData.isPostScrolling) {
          return;
        }

        categoryTab(_categoryController, category, idx);
      },
      child: Container(
        margin: EdgeInsets.only(top: 15, left: 20, right: 20),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'UTOIMAGE'),
            ),
            Visibility(
              visible: (_categoryPage == idx),
              child: Container(
                width: 20,
                height: 5,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(3)), color: Color(0xff26A69A), shape: BoxShape.rectangle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static InkWell getContent(BuildContext context, int length, int position, Post post) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        goContentPage(context, post);
      },
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.13,
            margin: EdgeInsets.only(top: 5, left: 5, bottom: 20),
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.23,
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        width: MediaQuery.of(context).size.width * 0.57,
                        margin: EdgeInsets.only(top: 6, left: 20, right: 15),
                        child: Text(post.imageText,
                            overflow: TextOverflow.visible, style: TextStyle(color: Colors.black, height: 1.2, fontSize: 15, fontFamily: 'UTOIMAGE')),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        width: MediaQuery.of(context).size.width * 0.57,
                        margin: EdgeInsets.only(top: 20, left: 20, right: 15),
                        child: Text(post.origin, style: GoogleFonts.notoSans(textStyle: TextStyle(color: Colors.black, height: 1.3, fontSize: 15))),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
