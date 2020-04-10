part of pulmonary_monitor_app;

class App extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: CarpMobileSensingApp(key: key),
    );
  }
}

class CarpMobileSensingApp extends StatefulWidget {
  CarpMobileSensingApp({Key key}) : super(key: key);

  CarpMobileSensingAppState createState() => CarpMobileSensingAppState();
}

class CarpMobileSensingAppState extends State<CarpMobileSensingApp> {
  int _selectedIndex = 0;

  final _pages = [
    TaskList(),
    StudyVisualization(),
    DataVisualization(),
  ];

  void initState() async {
    super.initState();
    await settings.init();
    await bloc.init();
    bloc.start();
  }

  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.spellcheck), title: Text('Tasks')),
          BottomNavigationBarItem(icon: Icon(Icons.school), title: Text('Study')),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), title: Text('Data')),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
//      floatingActionButton: new FloatingActionButton(
//        onPressed: _restart,
//        tooltip: 'Restart study & probes',
//        child: bloc.isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
//      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _stop() {
    setState(() {
      if (bloc.isRunning) bloc.stop();
    });
  }

  void _restart() {
    setState(() {
      if (bloc.isRunning)
        bloc.pause();
      else
        bloc.resume();
    });
  }
}
