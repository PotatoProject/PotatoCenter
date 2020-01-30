import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:potato_center/provider/current_build.dart';
import 'package:provider/provider.dart';

class DeviceInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentBuild = Provider.of<CurrentBuildProvider>(context);

    String version =
        currentBuild.version != "" ? currentBuild.version : "?.?.?+?";
    String type = currentBuild.type != "" ? currentBuild.type : "Unknown";
    String device = currentBuild.device.length > 15
        ? currentBuild.device.substring(0, 12) + "..."
        : currentBuild.device;
    String codename =
        currentBuild.codename != "" ? currentBuild.codename : "unknown";
    String date = currentBuild.date;

    return Card(
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
                Text("Current build info",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Divider(height: 8, color: Colors.transparent),
                Text("- Version: $version"),
                Divider(height: 4, color: Colors.transparent),
                Text("- Type: $type"),
                Divider(height: 4, color: Colors.transparent),
                Text("- Device: $device ($codename)"),
                Divider(height: 4, color: Colors.transparent),
                Text("- Date: $date"),
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                MdiIcons.informationOutline,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                AndroidFlutterUpdater.startActivity(
                  pkg: "com.android.settings",
                  cls: "com.android.settings.Settings\$MyDeviceInfoActivity"
                );
              },
              padding: EdgeInsets.all(0),
            ),
          ],
        ),
      ),
    );
  }
}
