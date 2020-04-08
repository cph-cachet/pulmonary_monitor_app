part of pulmonary_monitor_app;

class Read_aloud extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Read_aloudState();
  }
}

class _Read_aloudState extends State<Read_aloud> {
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
          title: new Text("Read Aloud"),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Coronavirus disease (COVID-19) is an infectious disease caused by a new virus. The disease causes respiratory illness (like the flu) with symptoms such as a cough, fever, and in more severe cases, difficulty breathing. You can protect yourself by washing your hands frequently, avoiding touching your face, and avoiding close contact (1 meter or 3 feet) with people who are unwell',
                maxLines: 13,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Open Sans',
                    fontSize: 18),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new RaisedButton(
                    padding: const EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: _start,
                    child: new Text("Start reading  "),
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
