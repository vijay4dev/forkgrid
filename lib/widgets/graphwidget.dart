import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:intl/intl.dart';

class ForkYouGraphWidget extends StatefulWidget {
  final String userUrl;

  const ForkYouGraphWidget({super.key, required this.userUrl});

  @override
  State<ForkYouGraphWidget> createState() => _ForkYouGraphWidgetState();
}

class _ForkYouGraphWidgetState extends State<ForkYouGraphWidget> {
  late final Future<Map<String, dynamic>> _activityData;

  

  @override
  void initState() {
    super.initState();
    _activityData = _fetchAndParseData();
  }


  Future<Map<String, dynamic>> _fetchAndParseData() async {
    try {
      final response = await http.get(Uri.parse(widget.userUrl));
      if (response.statusCode == 200) {
        final document = html.parse(response.body);

        // 1️⃣ Get the grid opacity values
        final divs = document.querySelectorAll('div.grid > div.flex > div');
        final List<double> opacities = [];

        for (var div in divs) {
          final style = div.attributes['style'];
          if (style != null && style.contains('opacity')) {
            final opacityRegex = RegExp(r'opacity:([\d.]+)');
            final match = opacityRegex.firstMatch(style);
            if (match != null) {
              // opacities.add(double.parse(match.group(1)!));
              double value = double.parse(match.group(1)!);

              // ➕ add 0.5 but cap at 1.0 (so it doesn’t exceed max opacity)
              opacities.add((value + 0.2).clamp(0.0, 1.0));
            }
          } else {
            opacities.add(0.0);
          }
        }

        // 2️⃣ Get the active days & coverage text
        final activeDiv = document.querySelector(
          'div.flex.items-center.p-6.text-xs.text-muted-foreground.pt-0',
        );
        final activeText = activeDiv != null
            ? activeDiv.text.replaceAll(RegExp(r'\s+'), ' ').trim()
            : '';

        return {'opacities': opacities, 'activeText': activeText};
      } else {
        throw Exception('Failed to load data from the URL');
      }
    } on SocketException {
      throw Exception('No Internet Connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _activityData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Image.asset("assets/loading.gif", height: 100, width: 100),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString().contains('No Internet')
                  ? 'No Internet Connection'
                  : 'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        } else if (snapshot.hasData) {
          final opacities = snapshot.data!['opacities'] as List<double>;
          final activeText = snapshot.data!['activeText'] as String;

          return _buildActivityGrid(opacities, activeText);
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }

  Widget _buildActivityGrid(List<double> opacities, String activeText) {
    List<Widget> weekColumns = [];

    final String monthName = DateFormat('MMMM').format(DateTime.now());

    final int totalCells = opacities.length;
    final int totalRows = (opacities.length / 7).ceil(); // total number of rows


    for (int i = 0; i < opacities.length; i += 7) {
      List<Widget> dayCells = [];
      final int currentRow = (i / 7).floor(); // current row index (0-based)


      for (int j = 0; j < 7; j++) {
        if (i + j < opacities.length) {
          final double opacity = opacities[i + j];
          bool isTopLeft = (i == 0 && j == 0); // first box top-left
      bool isBottomLeft = (currentRow == totalRows - 1 && j == 0); // last row, first box
      bool isBottomRight = (currentRow == totalRows - 1 && j == 6) || (i + j == totalCells - 1 && j != 0); // last row, last box or last cell
      bool isTopRight = (i == 0 && j == 6); // first row, last box (optional if needed)

      BorderRadius cellRadius;
      if (isTopLeft) {
        cellRadius = const BorderRadius.only(topLeft: Radius.circular(15));
      } else if (isBottomLeft) {
        cellRadius = const BorderRadius.only(topRight: Radius.circular(15));
      } else if (isBottomRight) {
        cellRadius = const BorderRadius.only(bottomRight: Radius.circular(15));
      } else if (isTopRight) {
        cellRadius = const BorderRadius.only(bottomLeft: Radius.circular(15));
      } else {
        cellRadius = BorderRadius.circular(5);
      }
          dayCells.add(
            Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: opacity > 0
                      ? Colors.deepOrange.withOpacity(opacity)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: cellRadius,
                  border: opacity > 0
                      ? Border.all(width: 0)
                      : BoxBorder.all(
                          width: opacity < 0 ? 0 : 1.2,
                          color: opacity > 0
                              ? Colors.transparent
                              : Colors.black.withOpacity(0.2),
                        ),
                ),
              ),
            ),
          );
        }
      }
      weekColumns.add(
        Column(mainAxisAlignment: MainAxisAlignment.center, children: dayCells),
      );
    }

    return Padding(
      padding: EdgeInsetsGeometry.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // vertically center
        crossAxisAlignment: CrossAxisAlignment.center, // horizontally center
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: weekColumns,
            ),
          ),
          SizedBox(height: 10,),
          Text( " - ${monthName.toUpperCase()} - " , textAlign: TextAlign.center, style: TextStyle(color: Colors.white , fontSize: 15 , letterSpacing: 4 , fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }
}
