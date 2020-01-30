import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/models/download.dart';
import 'package:potato_center/provider/app_info.dart';
import 'package:potato_center/provider/download.dart';
import 'package:potato_center/provider/sheet_data.dart';
import 'package:potato_center/ui/bottom_sheet.dart';
import 'package:potato_center/ui/custom_bottom_sheet.dart';
import 'package:potato_center/ui/no_glow_scroll_behavior.dart';
import 'package:potato_center/widget/device_info_card.dart';
import 'package:potato_center/widget/status_bar.dart';
import 'package:provider/provider.dart';

import 'provider/current_build.dart';

BorderRadius _kBorderRadius = BorderRadius.circular(12);

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
            theme: ThemeData.light().copyWith(accentColor: appInfo.accentColor),
            darkTheme:
                ThemeData.dark().copyWith(accentColor: appInfo.accentColor),
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
    updateColors(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: MediaQuery.of(context).padding.top,
            child: StatusBar(),
          ),
          ListView(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
            children: <Widget>[_homeCards],
          ),
        ],
      ),
      floatingActionButton: _floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: _bottomAppBar,
    );
  }

  Widget get _homeCards => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DeviceInfoCard(),
        ],
      );

  Widget _paddedChild(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: child,
      );

  Widget get _divider => Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.all(12),
          child: Center(
            child: Container(
              height: 5,
              width: 175,
              decoration: BoxDecoration(
                color: HSLColor.fromColor(Theme.of(context).accentColor)
                    .withLightness(0.85)
                    .toColor(),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      );

  get _updatesList => Builder(
        builder: (context) {
          final downloadProvider = Provider.of<DownloadProvider>(context);
          return PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: downloadProvider.downloads.length,
            itemBuilder: (context, index) =>
                _paddedChild(_buildInfoCard(downloadProvider.downloads[index])),
          );
        },
      );

  Widget _buildInfoCard(DownloadModel download) => Builder(
        builder: (context) => Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: _kBorderRadius),
          color: HSLColor.fromColor(Theme.of(context).accentColor)
              .withLightness(0.85)
              .toColor(),
          child: DefaultTextStyle(
            style: TextStyle(
                color: HSLColor.fromColor(Theme.of(context).accentColor)
                    .withLightness(0.4)
                    .toColor()),
            child: IconTheme(
              data: Theme.of(context).iconTheme.copyWith(
                    color: HSLColor.fromColor(Theme.of(context).accentColor)
                        .withLightness(0.4)
                        .toColor(),
                  ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // Hack, this can be improved.
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'New build',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                          Text(
                              '• Version - ${download.version} (${download.releaseType})'),
                          Text('• Date - ${download.timestamp}'),
                          Text(
                              '• Status - ${download.status == UpdateStatus.UNKNOWN ? 'Available' : formatStatus(download.status.toString())}'),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _downloadStatusRow(download),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _downloadStatusRow(DownloadModel download) => Builder(
        builder: (context) {
          final Color foregroundColor =
              HSLColor.fromColor(Theme.of(context).accentColor)
                  .withLightness(0.4)
                  .toColor();
          double iconSize = 20;

          final appInfo = Provider.of<AppInfoProvider>(context);
          return IconTheme(
            data: Theme.of(context)
                .iconTheme
                .copyWith(size: iconSize, color: foregroundColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: download.status != UpdateStatus.DELETED &&
                      download.status != UpdateStatus.INSTALLING &&
                      download.status != UpdateStatus.UNKNOWN &&
                      download.status != UpdateStatus.STARTING,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.close),
                    ),
                    onTap: () => download.cancelAndDelete(),
                  ),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.DOWNLOADING ||
                      download.status == UpdateStatus.PAUSED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(download.status == UpdateStatus.PAUSED
                          ? Icons.play_arrow
                          : Icons.pause),
                    ),
                    onTap: () => download.status == UpdateStatus.PAUSED
                        ? download.resumeDownload()
                        : download.pauseDownload(),
                  ),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.DOWNLOADING ||
                      download.status == UpdateStatus.PAUSED ||
                      download.status == UpdateStatus.STARTING,
                  child: _downloadProgressIndicator(download),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.DOWNLOADED ||
                      download.status == UpdateStatus.VERIFICATION_FAILED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.vpn_key),
                    ),
                    onTap: () => download.verifyDownload(),
                  ),
                ),
                Visibility(
                  visible: download.status == UpdateStatus.VERIFIED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.perm_device_information),
                    ),
                    onTap: () {
                      final buttonTextColor =
                          HSLColor.fromColor(Theme.of(context).accentColor)
                              .withLightness(0.4)
                              .toColor();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Install Update'),
                          shape: RoundedRectangleBorder(
                            borderRadius: _kBorderRadius,
                          ),
                          content: Text(
                              'This operation will install the update. Continue?'),
                          actions: <Widget>[
                            FlatButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(color: buttonTextColor),
                                ),
                                onPressed: () => Navigator.of(context).pop()),
                            FlatButton(
                              child: Text(
                                'Yes',
                                style: TextStyle(color: buttonTextColor),
                              ),
                              onPressed: () {
                                download.installUpdate();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: (download.status != UpdateStatus.DOWNLOADING &&
                          download.status != UpdateStatus.DOWNLOADED &&
                          download.status != UpdateStatus.STARTING &&
                          download.status != UpdateStatus.VERIFYING &&
                          download.status != UpdateStatus.VERIFIED &&
                          download.status != UpdateStatus.INSTALLING &&
                          download.status != UpdateStatus.INSTALLED &&
                          download.status != UpdateStatus.PAUSED) &&
                      download.notes != "",
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.info_outline),
                    ),
                    onTap: () async {
                      final buttonTextColor =
                          HSLColor.fromColor(Theme.of(context).accentColor)
                              .withLightness(0.4)
                              .toColor();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Notes for release"),
                          shape: RoundedRectangleBorder(
                            borderRadius: _kBorderRadius,
                          ),
                          content: Text(download.notes),
                          actions: <Widget>[
                            FlatButton(
                                child: Text(
                                  "Close",
                                  style: TextStyle(color: buttonTextColor),
                                ),
                                onPressed: () => Navigator.of(context).pop()),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Visibility(
                  visible: download.status != UpdateStatus.DOWNLOADING &&
                      download.status != UpdateStatus.DOWNLOADED &&
                      download.status != UpdateStatus.STARTING &&
                      download.status != UpdateStatus.VERIFYING &&
                      download.status != UpdateStatus.VERIFIED &&
                      download.status != UpdateStatus.INSTALLING &&
                      download.status != UpdateStatus.INSTALLED &&
                      download.status != UpdateStatus.PAUSED,
                  child: GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        appInfo.storageStatus == PermissionStatus.granted
                            ? Icons.file_download
                            : Icons.warning,
                      ),
                    ),
                    onTap: () async {
                      if (appInfo.storageStatus != PermissionStatus.granted) {
                        appInfo.storageStatus = (await PermissionHandler()
                                .requestPermissions([PermissionGroup.storage]))[
                            PermissionGroup.storage];
                        if (appInfo.storageStatus != PermissionStatus.granted)
                          return;
                      }
                      final buttonTextColor =
                          HSLColor.fromColor(Theme.of(context).accentColor)
                              .withLightness(0.4)
                              .toColor();
                      await AndroidFlutterUpdater.needsWarn()
                          ? showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Warning!"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: _kBorderRadius,
                                ),
                                content: Text(
                                    "You appear to be on mobile data! Would you like to still continue?"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      "No",
                                      style: TextStyle(color: buttonTextColor),
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  FlatButton(
                                    child: Text(
                                      "Yes",
                                      style: TextStyle(color: buttonTextColor),
                                    ),
                                    onPressed: () {
                                      download.startDownload();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            )
                          : download.startDownload();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _downloadProgressIndicator(DownloadModel download) => Builder(
        builder: (context) {
          final Color foregroundColor =
              HSLColor.fromColor(Theme.of(context).accentColor)
                  .withLightness(0.4)
                  .toColor();
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Center(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 0,
                    bottom: 0,
                    left: 0,
                    top: 0,
                    child: Center(
                      child: Text(
                        download.downloadProgress <= 0
                            ? 0.toString()
                            : download.downloadProgress.toString(),
                      ),
                    ),
                  ),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                    strokeWidth: 2.5,
                    value: download.downloadProgress <= 0 ||
                            download.status == UpdateStatus.STARTING
                        ? null
                        : download.downloadProgress / 100.0,
                  ),
                ],
              ),
            ),
          );
        },
      );

  Widget get _floatingActionButton => Builder(
        builder: (context) => FloatingActionButton(
          elevation: 0,
          backgroundColor: Theme.of(context).accentColor,
          child: Icon(
            Icons.refresh,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          onPressed: () async =>
              await Provider.of<DownloadProvider>(context).loadData(),
        ),
      );

  Widget get _bottomAppBar => Builder(builder: (context) {
        final sheetData = Provider.of<SheetDataProvider>(context);

        return Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 8),
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
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    if (!sheetData.isHandleVisible)
                      sheetData.isHandleVisible = true;

                    showModalBottomSheetApp(
                      dismissOnTap: false,
                      context: context,
                      builder: (context) => BottomSheetContents(),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(MdiIcons.accountGroupOutline),
                  onPressed: () => launchUrl("https://potatoproject.co/team"),
                ),
              ],
            ),
          ),
        );
      });

  /*Widget get _bottomAppBar => ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: _kBorderRadius.topLeft,
          topRight: _kBorderRadius.topRight,
        ),
        child: Builder(
          builder: (context) {
            final appInfo = Provider.of<AppInfoProvider>(context);
            final sheetData = Provider.of<SheetDataProvider>(context);
            return BottomAppBar(
              color: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              shape: CircularNotchedRectangle(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.fastfood),
                      onPressed: () => AndroidFlutterUpdater.startActivity(
                        pkg: 'com.potatoproject.fries',
                        cls:
                            'com.potatoproject.fries.TopLevelSettingsActivity',
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () =>
                          launchUrl("https://potatoproject.co/team"),
                    ),
                    Spacer(flex: 4),
                    AnimatedCrossFade(
                      firstChild: IconButton(
                          icon: Icon(Icons.brightness_medium),
                          onPressed: () => appInfo.isDark = true),
                      secondChild: IconButton(
                          icon: Icon(Icons.brightness_4),
                          onPressed: () => appInfo.isDark = false),
                      crossFadeState: !appInfo.isDark
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 300),
                    ),
                    Spacer(),
                    GestureDetector(
                      onLongPress: () {
                        if (appInfo.isDeveloper) {
                          if (!sheetData.isHandleVisible)
                            sheetData.isHandleVisible = true;
                          showModalBottomSheetApp(
                            dismissOnTap: false,
                            context: context,
                            builder: (context) =>
                                DeveloperBottomSheetContents(),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                          );
                        }
                      },
                      child: IconButton(
                        icon: Icon(
                          appInfo.isDeveloper
                              ? Icons.bug_report
                              : Icons.keyboard_arrow_up,
                        ),
                        onPressed: () {
                          if (!sheetData.isHandleVisible)
                            sheetData.isHandleVisible = true;
                          showModalBottomSheetApp(
                            dismissOnTap: false,
                            context: context,
                            builder: (context) => BottomSheetContents(),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20),
                          );
                        },
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            );
          },
        ),
      );*/
}
