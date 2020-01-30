import 'package:android_flutter_updater/android_flutter_updater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:potato_center/internal/methods.dart';
import 'package:potato_center/provider/app_info.dart';
import 'package:potato_center/provider/download.dart';
import 'package:potato_center/provider/sheet_data.dart';
import 'package:provider/provider.dart';

BorderRadius _kBorderRadius = BorderRadius.circular(12);

class BottomSheetContents extends StatelessWidget {
  final int currentValue = 0;
  final List<String> intervals = [
    'Never',
    'Once a day',
    'Once a week',
    'Once a month'
  ];

  final List<int> intervalIndex = [0, 1, 2, 3];

  @override
  Widget build(BuildContext context) {
    final appInfo = Provider.of<AppInfoProvider>(context);
    final sheetData = Provider.of<SheetDataProvider>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        toggleableActiveColor: Theme.of(context).accentColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Update check interval'),
            trailing: DropdownButton(
              value: sheetData.checkInterval,
              items: intervalIndex
                  .map((int val) => DropdownMenuItem(
                        value: val,
                        child: Text(intervals[val]),
                      ))
                  .toList(),
              onChanged: (v) => sheetData.checkInterval = v,
            ),
          ),
          ListTile(
            title: Text('Mobile data warning'),
            trailing: Switch(
              value: sheetData.dataWarn,
              onChanged: (v) => sheetData.dataWarn = v,
            ),
          ),
          ListTile(
              title: Text('Delete updates when installed'),
              trailing: Switch(
                value: sheetData.autoDelete,
                onChanged: (v) => sheetData.autoDelete = v,
              )),
          sheetData.isABDevice
              ? ListTile(
                  title: Text('Install updates faster'),
                  trailing: Switch(
                      value: sheetData.perfMode,
                      onChanged: (v) => sheetData.perfMode = v),
                )
              : Container(),
          Divider(
            height: 1,
          ),
          Container(
              height: 64,
              width: MediaQuery.of(context).size.width,
              child: PageView(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.code,
                          color: Theme.of(context).iconTheme.color.withOpacity(0.7),
                        ),
                        onPressed: () =>
                            launchUrl('https://potatoproject.co/changelog'),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.public,
                          color: Theme.of(context).iconTheme.color.withOpacity(0.7),
                        ),
                        onPressed: () => launchUrl('https://potatoproject.co'),
                      ),
                      IconButton(
                        icon: Icon(
                          MdiIcons.twitter,
                          color: Theme.of(context).iconTheme.color.withOpacity(0.7),
                        ),
                        onPressed: () =>
                            launchUrl('https://twitter.com/PotatoAndroid'),
                      ),
                      IconButton(
                        icon: Icon(
                          MdiIcons.telegram,
                          color: Theme.of(context).iconTheme.color.withOpacity(0.7),
                        ),
                        onPressed: () =>
                            launchUrl('https://t.me/SaucyPotatoesOfficial'),
                      ),
                    ],
                  ),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.device_unknown),
                      onPressed: () {
                        if (!appInfo.isDeveloper) {
                          appInfo.devCounter++;
                          if (appInfo.isDeveloper) Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class DeveloperBottomSheetContents extends StatefulWidget {
  @override
  _DeveloperBottomSheetContentsState createState() =>
      _DeveloperBottomSheetContentsState();
}

class _DeveloperBottomSheetContentsState
    extends State<DeveloperBottomSheetContents> {
  @override
  Widget build(BuildContext context) {
    final appInfo = Provider.of<AppInfoProvider>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        toggleableActiveColor: Theme.of(context).accentColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FutureBuilder(
            initialData: 'unknown',
            future: AndroidFlutterUpdater.getReleaseType(),
            builder: (context, snapshot) => ListTile(
              title: Text('Update channel'),
              subtitle: Text('Current: ${snapshot.data}'),
              trailing: RaisedButton(
                color: Theme.of(context).accentColor,
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ChannelSelector(
                    currentChannel: snapshot.data,
                  ),
                ),
                child: Text(
                  'Change',
                  style: TextStyle(color: Theme.of(context).bottomAppBarColor),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text('Build verification'),
            trailing: FutureBuilder(
              initialData: true,
              future: AndroidFlutterUpdater.getVerify(),
              builder: (context, snapshot) => Switch(
                value: snapshot.data,
                onChanged: (b) => AndroidFlutterUpdater.setVerify(b)
                    .then((v) => setState(() {})),
              ),
            ),
          ),
          ListTile(
            title: Text('Remove debug menu'),
            onTap: () {
              appInfo.isDeveloper = false;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class ChannelSelector extends StatefulWidget {
  final String currentChannel;

  ChannelSelector({this.currentChannel});

  @override
  _ChannelSelectorState createState() => _ChannelSelectorState();
}

class _ChannelSelectorState extends State<ChannelSelector> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentChannel ?? "");
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _buttonTextStyle =
        TextStyle(color: Theme.of(context).accentColor);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: _kBorderRadius,
      ),
      title: Text('Update channel'),
      content: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Channel name'),
            validator: (value) {
              if (value.isEmpty)
                return 'Please enter a channel name';
              else
                return null;
            },
          ),
        )
      ]),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: _buttonTextStyle),
        ),
        FlatButton(
          onPressed: () async {
            await AndroidFlutterUpdater.setReleaseType('__default__');
            Navigator.of(context).pop();
            await Provider.of<DownloadProvider>(context).loadData();
          },
          child: Text('Reset', style: _buttonTextStyle),
        ),
        FlatButton(
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              await AndroidFlutterUpdater.setReleaseType(_controller.text);
              Navigator.of(context).pop();
              await Provider.of<DownloadProvider>(context).loadData();
            }
          },
          child: Text('Apply', style: _buttonTextStyle),
        ),
      ],
    );
  }
}
