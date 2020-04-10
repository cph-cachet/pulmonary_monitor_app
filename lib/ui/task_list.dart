part of pulmonary_monitor_app;

class TaskList extends StatefulWidget {
  const TaskList({Key key}) : super(key: key);

  static const String routeName = '/tasklist';

  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    //Iterable<Widget> taskTiles = ListTile.divideTiles(
    //    context: context, tiles: bloc.userTasks.map<Widget>((task) => _buildTaskTile(context, task)));

    List<UserTaskModel> tasks = bloc.userTasks.toList().reversed.toList();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Tasks'),
        //TODO - move actions/settings icon to the app level.
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS ? Icons.more_horiz : Icons.more_vert,
            ),
            tooltip: 'Settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView.builder(
          itemCount: bloc.userTasks.length,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          itemBuilder: (context, index) => _buildTaskCard(context, tasks[index]),
        ),
      ),
    );
  }

  void _showSettings() {
    Scaffold.of(context).showSnackBar(const SnackBar(content: Text('Settings not implemented yet...')));
  }

  Widget _buildTaskCard(BuildContext context, UserTaskModel task) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: task.typeIcon,
              title: Text(task.heading),
              subtitle: Text('${task.description}\nAbout ${task.minutesToComplete} minutes to complete'),
              trailing: task.stateIcon,
            ),
            // TODO - only add button if there is a task to do. Might be an info card.
            (task.task.state != UserTaskState.done)
                ? ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: const Text('PRESS HERE TO FINISH TASK'),
                        onPressed: () {
                          setState(() {
                            task.task.onPressed(context);
                          });
                        },
                      ),
//                FlatButton(
//                  child: const Text('LISTEN'),
//                  onPressed: () {/* ... */},
//                ),
                    ],
                  )
                : Text(""),
          ],
        ),
      ),
    );
  }

  Widget tile_build(BuildContext context) {
    Iterable<Widget> taskTiles = ListTile.divideTiles(
        context: context, tiles: bloc.userTasks.map<Widget>((task) => _buildTaskTile(context, task)));

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Tasks'),
        //TODO - move actions/settings icon to the app level.
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS ? Icons.more_horiz : Icons.more_vert,
            ),
            tooltip: 'Settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView(
          //itemCount: tasks.length,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          children: taskTiles.toList(),
        ),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, UserTaskModel task) {
    return ListTile(
      isThreeLine: true,
      leading: task.typeIcon,
      title: Text(task.heading),
      subtitle: Text(task.description),
      trailing: task.stateIcon,
    );
  }
}
