import 'package:flutter/material.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/provider/download.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final downloadProvider = Provider.of<DownloadProvider>(context);

    return Container(
      color: Colors.transparent,
      height: 60,
      child: Row(
        children: <Widget>[
          VerticalDivider(
            color: Colors.transparent,
            width: 16,
          ),
          Icon(getStatusInfo(downloadProvider, true) as IconData,
              size: 36, color: Theme.of(context).accentColor),
          VerticalDivider(
            color: Colors.transparent,
            width: 16,
          ),
          Text(
            getStatusInfo(downloadProvider, false) as String,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 22,
              color: Theme.of(context).accentColor,
              fontFamily: "GoogleSans",
            ),
          ),
        ],
      ),
    );
  }
}
