import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/models/download.dart';
import 'package:potato_center/provider/app_info.dart';
import 'package:provider/provider.dart';

BorderRadius _kBorderRadius = BorderRadius.circular(12);

class BuildInfoCard extends StatelessWidget {
  final DownloadModel download;
  final bool latest;

  BuildInfoCard({
    @required this.download,
    this.latest = false,
  });

  @override
  Widget build(BuildContext context) {
    String version = download.version;
    String type = download.releaseType;
    String date = download.timestamp;
    String size = totalSizeInMb(sizeStr: download.size).toString();

    return Card(
      color: latest ? Theme.of(context).accentColor : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Visibility(
                  visible: latest,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Latest build",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: latest
                              ? Theme.of(context)
                                          .accentColor
                                          .computeLuminance() >
                                      0.5
                                  ? Colors.black
                                  : Colors.white
                              : null,
                        ),
                      ),
                      Divider(height: 8, color: Colors.transparent),
                    ],
                  ),
                ),
                Text(
                  "- Version: $version",
                  style: TextStyle(
                    color: latest
                        ? Theme.of(context).accentColor.computeLuminance() > 0.5
                            ? Colors.black.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9)
                        : Theme.of(context).textTheme.title.color.withOpacity(0.7),
                  ),
                ),
                Divider(height: 4, color: Colors.transparent),
                Text(
                  "- Type: $type",
                  style: TextStyle(
                    color: latest
                        ? Theme.of(context).accentColor.computeLuminance() > 0.5
                            ? Colors.black.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9)
                        : Theme.of(context).textTheme.title.color.withOpacity(0.7),
                  ),
                ),
                Divider(height: 4, color: Colors.transparent),
                Text(
                  "- Size: $size MB",
                  style: TextStyle(
                    color: latest
                        ? Theme.of(context).accentColor.computeLuminance() > 0.5
                            ? Colors.black.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9)
                        : Theme.of(context).textTheme.title.color.withOpacity(0.7),
                  ),
                ),
                Divider(height: 4, color: Colors.transparent),
                Text(
                  "- Date: $date",
                  style: TextStyle(
                    color: latest
                        ? Theme.of(context).accentColor.computeLuminance() > 0.5
                            ? Colors.black.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9)
                        : Theme.of(context).textTheme.title.color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            Spacer(),
            _downloadStatusRow(download)
          ],
        ),
      ),
    );
  }

  Widget _downloadStatusRow(DownloadModel download) => Builder(
        builder: (context) {
          double iconSize = 24;

          final appInfo = Provider.of<AppInfoProvider>(context);
          return IconTheme(
            data: Theme.of(context).iconTheme.copyWith(
                size: iconSize,
                color: latest
                    ? Theme.of(context).accentColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white
                    : null),
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
                      child: Icon(MdiIcons.deleteOutline),
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
                      child: Icon(MdiIcons.cellphoneArrowDown),
                    ),
                    onTap: () {
                      final buttonTextColor = Theme.of(context).accentColor;
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
                      final buttonTextColor = Theme.of(context).accentColor;
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
                      final buttonTextColor = Theme.of(context).accentColor;
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
                VerticalDivider(
                  color: Colors.transparent,
                  width: 4,
                ),
              ],
            ),
          );
        },
      );

  Widget _downloadProgressIndicator(DownloadModel download) => Builder(
        builder: (context) {
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
                        style: TextStyle(
                            color: latest
                                ? Theme.of(context)
                                            .accentColor
                                            .computeLuminance() >
                                        0.5
                                    ? Colors.black
                                    : Colors.white
                                : null),
                      ),
                    ),
                  ),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(latest
                        ? Theme.of(context).accentColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white
                        : null),
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
}
