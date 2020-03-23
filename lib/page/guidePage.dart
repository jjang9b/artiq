import 'package:artiq/data.dart';
import 'package:artiq/func/func.dart';
import 'package:artiq/page/postPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GuidePage extends StatefulWidget {
  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  Func func = new Func();
  PageController _guideController = new PageController();
  double idx = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: FutureBuilder<List<Guide>>(
        future: func.getGuideList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  setState(() {
                    idx = _guideController.page;
                  });

                  return true;
                },
                child: PageView.builder(
                  controller: _guideController,
                  itemBuilder: (context, position) {
                    return Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data[position].image,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          height: MediaQuery.of(context).size.height * 0.05,
                          child: Text(
                            snapshot.data[position].title,
                            style: TextStyle(
                                fontSize: 20, fontFamily: "JSDongkang"),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: Text(
                            snapshot.data[position].text,
                            style: TextStyle(
                                fontSize: 16, fontFamily: "JSDongkang"),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          width: MediaQuery.of(context).size.width * 0.68,
                          margin: EdgeInsets.only(top: 8),
                          child: DotsIndicator(
                            dotsCount: snapshot.data.length,
                            position: idx.abs(),
                            decorator: DotsDecorator(
                              activeSize: Size.fromRadius(5),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              color: Colors.black26,
                              activeColor: Colors.red,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Visibility(
                          visible: (position == snapshot.data.length -1),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(context, CupertinoPageRoute(
                                  builder: (BuildContext context) {
                                return new PostPage();
                              }));
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.12,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(50, 30, 50, 30),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30))),
                                child: Text("들어가기",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "JSDongkang")),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  itemCount: snapshot.data.length,
                ));
          }

          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        },
      )),
    );
  }
}