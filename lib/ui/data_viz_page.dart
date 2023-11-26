part of pulmonary_monitor_app;

class DataVisualization extends StatelessWidget {
  const DataVisualization({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Visualization'),
      ),
      body: const Center(
        child: Icon(
          Icons.show_chart,
          size: 100,
          color: CACHET.DARK_BLUE,
        ),
        //child: CircularProgressIndicator(),
      ),
    );
  }
}
