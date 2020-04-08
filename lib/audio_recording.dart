part of pulmonary_monitor_app;

class Audio_recording extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _AusdioState();
  }
}

class _AusdioState extends State<Audio_recording> {
  String recoding = "";

  void subtractNumbers() {
    setState(() {
      recoding = "Stoped";
    });
  }

  void addNumbers() {
    setState(() {
      recoding = "Started";
    });
  }

  void _stop() {
    setState(() {
      if (bloc.isRunning) bloc.stop();
    });
  }

  void _start() {
    if (bloc.isRunning) {
    } else
      bloc.start();
  }

  void _restart() {
    setState(() {
      if (bloc.isRunning)
        bloc.pause();
      else
        bloc.resume();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Record coughing"),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                '$recoding',
                style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60.0,
                  fontFamily: 'Roboto',
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new RaisedButton(
                    padding: const EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: _start,
                    child: new Text("Start "),
                  ),
                  new RaisedButton(
                    onPressed: _stop,
                    textColor: Colors.white,
                    color: Colors.red,
                    padding: const EdgeInsets.all(8.0),
                    child: new Text(
                      "Stop",
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
