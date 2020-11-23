part of pulmonary_monitor_app;

class TaskList extends StatefulWidget {
  const TaskList({Key key}) : super(key: key);

  static const String routeName = '/tasklist';

  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    //Iterable<Widget> taskTiles = ListTile.divideTiles(
    //    context: context, tiles: bloc.userTasks.map<Widget>((task) => _buildTaskTile(context, task)));

    //List<UserTaskModel> tasks = bloc.userTasks.toList().reversed.toList();
    List<UserTask> tasks = bloc.tasks.reversed.toList();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Tasks'),
        //TODO - move actions/settings icon to the app level.
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.more_horiz
                  : Icons.more_vert,
            ),
            tooltip: 'Settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: StreamBuilder<UserTask>(
        stream: AppTaskController().userTaskEvents,
        builder: (context, AsyncSnapshot<UserTask> snapshot) {
          print('>> $snapshot');
          return Scrollbar(
            child: ListView.builder(
              itemCount: tasks.length,
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index) =>
                  _buildTaskCard(context, tasks[index]),
            ),
          );
        },
      ),
    );
  }

  void _showSettings() {
    Scaffold.of(context).showSnackBar(
        const SnackBar(content: Text('Settings not implemented yet...')));
  }

  Widget _buildTaskCard(BuildContext context, UserTask userTask) {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: StreamBuilder<UserTaskState>(
          stream: userTask.stateEvents,
          initialData: UserTaskState.initialized,
          builder: (context, AsyncSnapshot<UserTaskState> snapshot) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: taskTypeIcon[userTask.type],
                title: Text(userTask.title),
                subtitle: Text(userTask.description),
                trailing: taskStateIcon[userTask.state],
              ),
              // TODO - only add button if there is a task to do. Might be an info card.
              (userTask.state == UserTaskState.enqueued ||
                      userTask.state == UserTaskState.onhold)
                  ? ButtonBar(
                      children: <Widget>[
                        FlatButton(
                            child: const Text('PRESS HERE TO FINISH TASK'),
                            onPressed: () => userTask.onStart(context)),
                      ],
                    )
                  : Text(""),
            ],
          ),
        ),
      ),
    );
  }

//   Widget _buildTaskCard(BuildContext context, UserTask userTask) {
//     return Center(
//       child: Card(
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(15.0),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             ListTile(
//               leading: taskTypeIcon[userTask.type],
//               title: Text(userTask.title),
//               subtitle: Text(userTask.description),
//               trailing: taskStateIcon[userTask.state],
//             ),
//             // TODO - only add button if there is a task to do. Might be an info card.
//             (userTask.state != UserTaskState.done)
//                 ? ButtonBar(
//                     children: <Widget>[
//                       FlatButton(
//                         child: const Text('PRESS HERE TO FINISH TASK'),
//                         onPressed: () {
//                           setState(() {
//                             userTask.onStart(context);
//                           });
//                         },
//                       ),
// //                FlatButton(
// //                  child: const Text('LISTEN'),
// //                  onPressed: () {/* ... */},
// //                ),
//                     ],
//                   )
//                 : Text(""),
//           ],
//         ),
//       ),
//     );
//   }

  Map<String, Icon> get taskTypeIcon => {
        SurveyUserTask.WHO5_SURVEY_TYPE: Icon(
          Icons.design_services,
          color: CACHET.ORANGE,
          size: 40,
        ),
        SurveyUserTask.DEMOGRAPHIC_SURVEY_TYPE: Icon(
          Icons.person,
          color: CACHET.ORANGE,
          size: 40,
        ),
        SurveyUserTask.SURVEY_TYPE: Icon(
          Icons.description,
          color: CACHET.ORANGE,
          size: 40,
        ),
        AudioUserTask.AUDIO_TYPE: Icon(
          Icons.record_voice_over,
          color: CACHET.GREEN,
          size: 40,
        ),
        UserTask.SENSING_TYPE: Icon(
          Icons.settings_input_antenna,
          color: CACHET.CACHET_BLUE,
          size: 40,
        ),
        UserTask.ONE_TIME_SENSING_TYPE: Icon(
          Icons.settings_input_component,
          color: CACHET.CACHET_BLUE,
          size: 40,
        ),
      };

  // String taskStateLabel(UserTaskState state) {
  //   switch (state) {
  //     case UserTaskState.initialized:
  //       return "Initialized";
  //     case UserTaskState.enqueued:
  //       return "Enqueued";
  //     case UserTaskState.dequeued:
  //       return "Dequeued";
  //     case UserTaskState.started:
  //       return "Started";
  //     case UserTaskState.onhold:
  //       return "On Hold";
  //     case UserTaskState.done:
  //       return "Done";
  //     default:
  //       return "";
  //   }
  // }

  Map<UserTaskState, Icon> get taskStateIcon => {
        UserTaskState.initialized: Icon(Icons.stream, color: CACHET.YELLOW),
        UserTaskState.enqueued: Icon(Icons.notifications, color: CACHET.YELLOW),
        UserTaskState.dequeued: Icon(Icons.stop, color: CACHET.YELLOW),
        UserTaskState.started: Icon(Icons.play_arrow, color: CACHET.GREY_4),
        UserTaskState.onhold: Icon(Icons.pause, color: CACHET.GREY_4),
        UserTaskState.done: Icon(Icons.check, color: CACHET.GREEN),
      };
}
