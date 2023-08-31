part of pulmonary_monitor_app;

class StudyVisualization extends StatefulWidget {
  const StudyVisualization({Key? key}) : super(key: key);
  static const String routeName = '/study';

  @override
  StudyVizState createState() => StudyVizState(bloc.studyDeploymentModel);
}

class StudyVizState extends State<StudyVisualization> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  final double _appBarHeight = 256.0;

  final StudyDeploymentModel studyDeploymentModel;

  StudyVizState(this.studyDeploymentModel) : super();

  @override
  Widget build(BuildContext context) =>
      _buildStudyVisualization(context, bloc.studyDeploymentModel);

  Widget _buildStudyVisualization(
    BuildContext context,
    StudyDeploymentModel studyDeploymentModel,
  ) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: _appBarHeight,
            pinned: true,
            floating: false,
            snap: false,
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.document_scanner),
                tooltip: 'Informed Consent',
                onPressed: _showInformedConsent,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(studyDeploymentModel.title),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  studyDeploymentModel.image,
//                  Image.asset(
//                    bloc.study.image,
//                    fit: BoxFit.cover,
//                    height: _appBarHeight,
//                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
                _buildStudyPanel(context, studyDeploymentModel)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStudyPanel(
      BuildContext context, StudyDeploymentModel study) {
    List<Widget> children = [];

    children.add(AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: _buildStudyControllerPanel(context, study),
    ));

    for (var task in studyDeploymentModel.deployment.tasks) {
      children.add(_TaskPanel(task: task));
    }

    return children;
  }

  Widget _buildStudyControllerPanel(
      BuildContext context, StudyDeploymentModel study) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: themeData.dividerColor))),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.titleMedium!,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  width: 72.0,
                  child: const Icon(Icons.lightbulb_outline,
                      size: 50, color: CACHET.CACHET_BLUE)),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    _StudyControllerLine(study.title, heading: 'Title'),
                    _StudyControllerLine(study.description),
                    _StudyControllerLine(study.studyDeploymentId,
                        heading: 'Deployment ID'),
                    _StudyControllerLine(study.userID, heading: 'User ID'),
                    _StudyControllerLine(study.dataEndpoint,
                        heading: 'Data Endpoint'),
                    StreamBuilder<Measurement>(
                        stream: studyDeploymentModel.measurements,
                        builder:
                            (context, AsyncSnapshot<Measurement> snapshot) {
                          return _StudyControllerLine(
                              '${studyDeploymentModel.samplingSize}',
                              heading: 'Sample Size');
                        }),
                  ]))
            ],
          ),
        ),
      ),
    );
  }

  void _showInformedConsent() {
    Navigator.of(context).push(MaterialPageRoute<StatefulWidget>(
        builder: (context) => const InformedConsentPage()));
  }
}

class _StudyControllerLine extends StatelessWidget {
  final String? line, heading;

  const _StudyControllerLine(this.line, {this.heading}) : super();

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: (heading == null)
                ? Text(line!, textAlign: TextAlign.left, softWrap: true)
                : Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: '$heading: ',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: line),
                      ],
                    ),
                  )));
  }
}

class _TaskPanel extends StatelessWidget {
  const _TaskPanel({Key? key, this.task}) : super(key: key);

  final TaskConfiguration? task;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<Widget> children = task!.measures!
        .map((measure) => _MeasureLine(measure: measure))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: themeData.dividerColor))),
      child: DefaultTextStyle(
          style: Theme.of(context).textTheme.titleMedium!,
          child: SafeArea(
              top: false,
              bottom: false,
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  const Icon(Icons.description, size: 40, color: CACHET.ORANGE),
                  Text('  ${task!.name}',
                      style: themeData.textTheme.titleLarge),
                ]),
                Column(children: children)
                //Expanded(child: Column(children: children))
              ]))),
    );
  }
}

class _MeasureLine extends StatelessWidget {
  _MeasureLine({Key? key, this.measure}) : super(key: key) {
    assert(measure != null);
  }

  final Measure? measure;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Icon icon = (ProbeDescription.probeTypeIcon[measure!.type] != null)
        ? Icon(ProbeDescription.probeTypeIcon[measure!.type]!.icon, size: 25)
        : const Icon(Icons.memory, size: 25, color: CACHET.GREY_4);

    final String name = ProbeDescription.descriptors[measure?.type]?.name ??
        measure.runtimeType.toString();

    final List<Widget> columnChildren = [];
    columnChildren.add(Text(name));
    columnChildren
        .add(Text(measure.toString(), style: themeData.textTheme.bodySmall));

    final List<Widget> rowChildren = [];
    rowChildren.add(SizedBox(
        width: 72.0,
        child: IconButton(
          icon: icon,
          onPressed: null,
        )));
    rowChildren.addAll([
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren))
    ]);
    return MergeSemantics(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowChildren)),
    );
  }
}
