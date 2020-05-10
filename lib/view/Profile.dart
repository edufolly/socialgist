import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialgist/i18n.dart';
import 'package:socialgist/model/User.dart';
import 'package:socialgist/provider/AuthUserProvider.dart';
import 'package:socialgist/util/ColumnMessage.dart';
import 'package:socialgist/util/WaitingMessage.dart';

/*
My Gists ??

https://gist.github.com/edufolly/starred

r'<a class="link-overlay" href="https://gist.github.com/(?<user>.*)/(?<gist>.*)">'
 */

///
///
///
class Profile extends StatefulWidget {
  ///
  ///
  ///
  @override
  _ProfileState createState() => _ProfileState();
}

///
///
///
class _ProfileState extends State<Profile> {
  StreamController<User> _controller;

  // Example of a color with opacity shared in some places
  Color softWhite = Colors.white.withOpacity(0.5);

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    _controller = StreamController();
    _loadData();
  }

  ///
  ///
  ///
  void _loadData() async {
    AuthUserProvider provider = AuthUserProvider(context);
    User me = await provider.getObject();
    _controller.add(me);
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User me = snapshot.data;

          Map<String, Map<String, dynamic>> cards = {
            'Following'.i18n: {
              'qtd': me.following ?? 0,
            },
            'Followers'.i18n: {
              'qtd': me.followers ?? 0,
            },
            'Repositories'.i18n: {
              'qtd': (me.publicRepos ?? 0) + (me.totalPrivateRepos ?? 0),
            },
            'Gists'.i18n: {
              'qtd': (me.publicGists ?? 0) + (me.privateGists ?? 0),
            },
          };

          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    /// Header Bar
                    Container(
                      margin: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 15.0),
                      child: Row(
                        children: [
                          /// Company
                          hasInfo(me.company)
                              ? Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Icon(
                                        Icons.business,
                                        color: softWhite,
                                      ),
                                      SizedBox(height: 5.0),
                                      Text(
                                        me.company,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                    ],
                                  ),
                                )
                              : Spacer(),

                          /// Avatar
                          hasInfo(me.avatarUrl)
                              ? Expanded(
                                  /// CircleAvatar as a parent with a larger size and
                                  /// background color to create a border effect.
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                    minRadius: 22.0,
                                    maxRadius: 52.0,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      backgroundImage:
                                          NetworkImage(me.avatarUrl),
                                      minRadius: 20.0,
                                      maxRadius: 50.0,
                                    ),
                                  ),
                                )
                              : Spacer(),

                          /// Location
                          hasInfo(me.location)
                              ? Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        color: softWhite,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        me.location,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : Spacer(),
                        ],
                      ),
                    ),

                    /// Name
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        me.name ?? me.login,
                        style: GoogleFonts.openSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: softWhite,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    /// E-mail
                    if (hasInfo(me.email))
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          me.email,
                          style: Theme.of(context).textTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                      ),

                    /// Divider
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        '__________',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    /// Blog
                    if (hasInfo(me.blog))
                      Text(
                        me.blog,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
                sliver: SliverGrid.extent(
                  maxCrossAxisExtent: 200.0,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 15.0,
                  children: cards.keys
                      .map(
                        (key) => Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${cards[key]['qtd']}',
                                style: TextStyle(
                                  fontSize: 50.0,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              Text(
                                key,
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return ColumnMessage(
            errorMessage: snapshot.error,
          );
        }

        return WaitingMessage('Aguarde...');
      },
    );
  }

  ///
  ///
  ///
  bool hasInfo(String info) {
    return info != null && info.isNotEmpty;
  }

  ///
  ///
  ///
  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
