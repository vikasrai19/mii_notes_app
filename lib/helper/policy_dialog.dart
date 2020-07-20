import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PolicyDialog extends StatelessWidget {
  final double radius;
  final String fileName;
  final Function onPressed;
  PolicyDialog(
      {Key key,
      this.radius = 8,
      @required this.fileName,
      @required this.onPressed})
      : assert(fileName.contains('.md'),
            'The file must contain the .md extension'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 200)).then((value) {
                return rootBundle.loadString('assets/$fileName');
              }),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data,
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          FlatButton(
            padding: EdgeInsets.all(1),
            color: Theme.of(context).primaryColor,
            onPressed: onPressed,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radius),
                    bottomRight: Radius.circular(radius))),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(radius),
                    bottomRight: Radius.circular(radius)),
              ),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              alignment: Alignment.center,
              height: 50.0,
              width: double.infinity,
            ),
          )
        ],
      ),
    );
  }
}
