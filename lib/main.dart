import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/provider/app_info.dart';
import 'package:potato_center/provider/download.dart';
import 'package:potato_center/provider/sheet_data.dart';
import 'package:potato_center/ui/bottom_sheet.dart';
import 'package:potato_center/ui/no_glow_scroll_behavior.dart';
import 'package:potato_center/ui/themes.dart';
import 'package:potato_center/widget/build_info_card.dart';
import 'package:potato_center/widget/device_info_card.dart';
import 'package:potato_center/widget/status_bar.dart';
import 'package:provider/provider.dart';

import 'provider/current_build.dart';

void main() => runApp(PotatoCenterRoot());

class PotatoCenterRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrentBuildProvider>.value(
          value: CurrentBuildProvider(),
        ),
        ChangeNotifierProvider<AppInfoProvider>.value(
          value: AppInfoProvider(),
        ),
        ChangeNotifierProvider<SheetDataProvider>.value(
          value: SheetDataProvider(),
        ),
        ChangeNotifierProvider<DownloadProvider>.value(
          value: DownloadProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final appInfo = Provider.of<AppInfoProvider>(context);

          switch (appInfo.systemBrightness) {
            case Brightness.light:
              changeSystemBarsColors(
                  ThemeData.light().bottomAppBarColor, Brightness.dark);
              break;
            case Brightness.dark:
              changeSystemBarsColors(
                  ThemeData.dark().bottomAppBarColor, Brightness.light);
              break;
          }

          return MaterialApp(
            builder: (context, child) => ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: child,
            ),
            debugShowCheckedModeBanner: false,
            theme: Themes.light.copyWith(accentColor: appInfo.accentColor),
            darkTheme: Themes.dark.copyWith(accentColor: appInfo.accentColor),
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  void updateColors(BuildContext context) async {
    final appInfo = Provider.of<AppInfoProvider>(context);

    appInfo.systemBrightness = await AndroidFlutterUpdater.isCurrentThemeDark()
        ? Brightness.dark
        : Brightness.light;

    appInfo.updateMainColor();
  }

  @override
  Widget build(BuildContext context) {
    final DownloadProvider downloadProvider =
        Provider.of<DownloadProvider>(context);
    updateColors(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: MediaQuery.of(context).padding.top,
            child: StatusBar(),
          ),
          SizedBox.expand(
            child: ListView(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
              children: <Widget>[
                Column(
                  children:
                      List.generate(downloadProvider.downloads.length, (index) {
                    if (downloadProvider.downloads[index].status ==
                            UpdateStatus.VERIFIED ||
                        downloadProvider.downloads[index].status ==
                            UpdateStatus.DOWNLOADED) {
                      return BuildInfoCard(
                        download: downloadProvider.downloads[index],
                        latest: index == 0,
                      );
                    } else
                      return Container();
                  }),
                ),
                DeviceInfoCard(),
                ifUpdateWidget(Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 60),
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Theme.of(context)
                                .textTheme
                                .title
                                .color
                                .withOpacity(0.14)),
                      ),
                    ),
                  ]..addAll(List.generate(downloadProvider.downloads.length,
                        (index) {
                      if (!(downloadProvider.downloads[index].status ==
                              UpdateStatus.VERIFIED ||
                          downloadProvider.downloads[index].status ==
                              UpdateStatus.DOWNLOADED)) {
                        return BuildInfoCard(
                          download: downloadProvider.downloads[index],
                          latest: index == 0,
                        );
                      } else
                        return Container();
                    })),
                )),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: _bottomAppBar,
    );
  }

  Widget get _floatingActionButton => Builder(
        builder: (context) => FloatingActionButton(
          elevation: 0,
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(
            Icons.refresh,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          onPressed: () async =>
              await Provider.of<DownloadProvider>(context, listen: false)
                  .loadData(),
        ),
      );

  Widget get _bottomAppBar => Builder(
        builder: (context) {
          final appInfo = Provider.of<AppInfoProvider>(context);

          return Container(
            height: 60,
            decoration: BoxDecoration(
                color: Theme.of(context).bottomAppBarColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: Offset(0, -0.1),
                    spreadRadius: 2,
                  )
                ]),
            child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 48,
                        width: 48,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.menu,
                                color: Theme.of(context)
                                    .iconTheme
                                    .color
                                    .withOpacity(0.7),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Visibility(
                                visible: appInfo.isDeveloper,
                                child: Material(
                                  color: Theme.of(context).bottomAppBarColor,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: EdgeInsets.all(2),
                                    child: Icon(
                                      Icons.bug_report,
                                      size: 12,
                                      color: Theme.of(context)
                                          .iconTheme
                                          .color
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPress: () {
                                if (appInfo.isDeveloper) {
                                  showModalBottomSheet(
                                    isScrollControlled: false,
                                    context: context,
                                    builder: (context) =>
                                        DeveloperBottomSheetContents(),
                                  );
                                }
                              },
                              child: IconButton(
                                icon: Container(),
                                onPressed: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) => BottomSheetContents(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          MdiIcons.accountGroupOutline,
                          color: Theme.of(context)
                              .iconTheme
                              .color
                              .withOpacity(0.7),
                        ),
                        onPressed: () =>
                            launchUrl("https://potatoproject.co/team"),
                      ),
                    ],
                  ),
                )),
          );
        },
      );
}
