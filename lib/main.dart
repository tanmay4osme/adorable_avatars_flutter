import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:transparent_image/transparent_image.dart';

import 'adorable_row.dart';
import 'avatar_bloc.dart';
import 'credits.dart';

void main() => runApp(MyApp());

const BlueGrey = Color(0xff2D4359);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adorable Avatars',
      theme: ThemeData(
        fontFamily: "Proxima",
        primaryColor: BlueGrey,
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(title: 'Adorable Avatars'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int size = 285;
  TextEditingController identifierController;
  int currentSelectedIndex = 1;

  @override
  void initState() {
    super.initState();
    identifierController = new TextEditingController(text: 'abott@adorable.io');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Credits();
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/demo-bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: StreamBuilder(
                stream: avatarBloc.stream,
                initialData:
                    'https://api.adorable.io/avatars/285/abott@adorable.png',
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return Container();
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xffE14283))),
                      FadeInImage.memoryNetwork(
                        height: 300,
                        width: 300,
                        placeholder: kTransparentImage,
                        image: snapshot.data,
                      ),
                    ],
                  );
                },
              ),
            ),
            AdorableRow(
              title: "IDENTIFIER",
              selected: currentSelectedIndex == 1,
              onSelect: () {
                setState(() {
                  currentSelectedIndex = 1;
                });
              },
              child: TextField(
                controller: identifierController,
                style: TextStyle(
                    color: Colors.white, fontFamily: "Arial", fontSize: 18),
                decoration: InputDecoration.collapsed(
                    hintText: "enter text",
                    hintStyle: TextStyle(color: Colors.blueGrey)),
                onChanged: (newIdentifier) {
                  avatarBloc.updateIdentifier(newIdentifier);
                },
              ),
            ),
            AdorableRow(
              title: 'SIZE',
              selected: currentSelectedIndex == 2,
              onSelect: () {
                setState(() {
                  currentSelectedIndex = 2;
                });
              },
              title2: size.toString(),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Color(0xff667382),
                  inactiveTrackColor: Color(0xff667382),
                  trackHeight: 6.3,
                  thumbColor: Colors.white,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
                  trackShape: CustomTrackShape(),
                ),
                child: Slider(
                  value: size.toDouble(),
                  min: 40,
                  max: 285,
                  onChanged: (newSize) {
                    setState(() => size = newSize.round());
                  },
                  onChangeEnd: (newSize) {
                    avatarBloc.updateSize(newSize.round());
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Flexible(
                    flex: 8,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      color: Colors.white,
                      child: StreamBuilder(
                        stream: avatarBloc.stream,
                        initialData: "ok",
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (!snapshot.hasData) return Text("Loading");
                          return SelectableText.rich(TextSpan(
                              style: TextStyle(fontFamily: 'Source Code Pro'),
                              children: [
                                TextSpan(
                                    text: 'https://api.adorable.io/avatars/'),
                                TextSpan(
                                    text: avatarBloc.size.toString(),
                                    style: TextStyle(color: Color(0xffe14283))),
                                TextSpan(text: '/'),
                                TextSpan(
                                    text: avatarBloc.identifier,
                                    style: TextStyle(color: Color(0xffe14283)))
                              ]));
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: Material(
                        color: Color(0xff6ED8D6),
                        child: Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.content_copy),
                            tooltip: 'Copy to clipboard',
                            onPressed: () {
                              Clipboard.setData(
                                  new ClipboardData(text: avatarBloc.url));
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  backgroundColor: BlueGrey,
                                  content:
                                      new Text("Link copied to clipboard")));
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FlatButton(
              color: Color(0xffE14283),
              textColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Download avatar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              onPressed: () async {
                try {
                  // Saved with this method.
                  var imageId =
                      await ImageDownloader.downloadImage(avatarBloc.url);
                  if (imageId == null) {
                    return;
                  }
                } on PlatformException catch (error) {
                  print(error);
                }
              },
            ),
            SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

// CUSTOM SLIDER
class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
