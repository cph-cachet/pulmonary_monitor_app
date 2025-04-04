part of pulmonary_monitor_app;

class App extends StatelessWidget {
  const App({super.key});

  /// This methods is used to set up the entire app, including:
  Future<bool> init(BuildContext context) async {
    await LocationManager().requestPermission();
    await bloc.init();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: FutureBuilder(
        future: init(context),
        builder: (context, snapshot) => (!snapshot.hasData)
            ? Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: const Center(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator()],
                )))
            : PulmonaryMonitorApp(key: key),
      ),
    );
  }
}

class PulmonaryMonitorApp extends StatefulWidget {
  const PulmonaryMonitorApp({super.key});
  @override
  PulmonaryMonitorAppState createState() => PulmonaryMonitorAppState();
}

class PulmonaryMonitorAppState extends State<PulmonaryMonitorApp> {
  // when the app starts, show the task list (index =1) since the app may have
  // been started due to the user selecting a notification
  int _selectedIndex = 1;

  final _pages = [
    const StudyVisualization(),
    const TaskList(),
    const DataVisualization(),
  ];

  @override
  void dispose() {
    bloc.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Study'),
          BottomNavigationBarItem(icon: Icon(Icons.spellcheck), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Data'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
//      floatingActionButton: new FloatingActionButton(
//        onPressed: restart,
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

  void restart() {
    setState(() {
      if (bloc.isRunning) {
        bloc.stop();
      } else {
        bloc.start();
      }
    });
  }
}
