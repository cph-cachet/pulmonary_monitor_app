part of pulmonary_monitor_app;

class AudioMeasurePage extends StatefulWidget {
  static const String routeName = '/study/audio';

  final AudioUserTask? audioUserTask;

  AudioMeasurePage({Key? key, this.audioUserTask}) : super(key: key);

  @override
  AudioMeasurePageState createState() => AudioMeasurePageState(audioUserTask);
}

class AudioMeasurePageState extends State<AudioMeasurePage> {
  AudioUserTask? audioUserTask;

  AudioMeasurePageState(this.audioUserTask) : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Audio Measure'),
        ),
        body: Center(
            child: ListView(
          children: [
            image,
            titleSection,
            countDownSection,
            bottomSection,
          ],
        )));
  }

  Widget get image => Image.asset(
        'assets/images/audio.png',
        width: 600,
        fit: BoxFit.cover,
      );

  Widget get titleSection {
    return Container(
        padding: const EdgeInsets.only(top: 30, left: 8, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            audioUserTask!.title,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(audioUserTask!.description),
          Container(
            padding: const EdgeInsets.all(10),
            child: Text(
              audioUserTask!.instructions,
              softWrap: true,
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ]));
  }

  Widget get countDownSection {
    return Container(
        padding: const EdgeInsets.only(top: 80),
        alignment: FractionalOffset.center,
        child: StreamBuilder<int>(
            stream: audioUserTask!.countDownEvents,
            initialData: audioUserTask!.recordingDuration,
            builder: (context, AsyncSnapshot<int> snapshot) =>
                Text('00:${snapshot.data.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ))));
  }

  Widget get bottomSection {
    return Container(
        alignment: FractionalOffset.center,
        child: StreamBuilder<UserTaskState>(
            stream: audioUserTask!.stateEvents,
            builder: (context, AsyncSnapshot<UserTaskState> snapshot) {
              switch (snapshot.data) {
                case UserTaskState.enqueued:
                case UserTaskState.started:
                case UserTaskState.canceled:
                  return buttonSection;
                case UserTaskState.done:
                  return finishedSection;
                default:
                  return buttonSection;
              }
            }));
  }

  Widget get buttonSection {
    return Container(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            (audioUserTask!.state == UserTaskState.started)
                ? Text('RECORDING...')
                : Text('Press here to start recording...'),
            IconButton(
              iconSize: 80,
              color: CACHET.RED,
              icon: Icon(Icons.radio_button_checked),
              onPressed: () {
                audioUserTask!.onRecord();
              },
            ),
          ],
        ));
  }

  Widget get finishedSection {
    return Container(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('DONE!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
            OutlinedButton(
              child: const Text('PRESS HERE TO GO BACK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ));
  }
}
