import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../calendar_screen/models/weather_day_model.dart';
import '../models/weather_statistics_model.dart';

class ExportHelper {
  const ExportHelper._();

  static Future<String> exportCsv(List<WeatherDayModel> rows) async {
    final csv = const ListToCsvConverter().convert(<List<dynamic>>[
      <dynamic>[
        'Date',
        'Condition',
        'Temp',
        'Max',
        'Min',
        'Humidity',
        'Wind Speed',
        'Precipitation',
        'UV Index',
      ],
      ...rows.map(
        (e) => <dynamic>[
          e.date.toIso8601String(),
          e.condition,
          e.temp,
          e.tempMax,
          e.tempMin,
          e.humidity,
          e.windSpeed,
          e.precipitationAmount,
          e.uvIndex,
        ],
      ),
    ]);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/weather_statistics_export.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  static Future<String> exportPdf(WeatherStatisticsModel model) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Weather Statistics Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Average Temperature: ${model.avgTemp.toStringAsFixed(1)} C',
            ),
            pw.Text(
              'Maximum Temperature: ${model.maxTemp.toStringAsFixed(1)} C',
            ),
            pw.Text(
              'Minimum Temperature: ${model.minTemp.toStringAsFixed(1)} C',
            ),
            pw.Text('Rainy Days: ${model.rainyDays}'),
            pw.Text(
              'Average Humidity: ${model.avgHumidity.toStringAsFixed(1)}%',
            ),
            pw.Text(
              'Average Wind Speed: ${model.avgWindSpeed.toStringAsFixed(1)} m/s',
            ),
            pw.Text('Dominant Condition: ${model.dominantCondition}'),
          ],
        ),
      ),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/weather_statistics_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
