import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PercentageTile extends StatefulWidget {
  final String label;
  final double percentage;

  const PercentageTile({
    super.key,
    required this.label,
    required this.percentage,
  });

  @override
  State<PercentageTile> createState() => _PercentageTileState();
}

class _PercentageTileState extends State<PercentageTile> {
  @override
  Widget build(BuildContext context) {
    double labelpercentage = widget.percentage * 100;
    int labelint = labelpercentage.toInt();
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: "RobotoFlex",
                    fontSize: 16,
                    color: const Color.fromARGB(255, 58, 58, 58),
                  ),
                ),
                Text(
                  "$labelint%",
                  style: TextStyle(
                    fontFamily: "RobotoFlex",
                    fontSize: 16,
                    color: const Color.fromARGB(255, 58, 58, 58),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 10,
            width: MediaQuery.of(context).size.width - 60,
            barRadius: Radius.circular(10),
            percent: widget.percentage,
            progressColor: Color.fromARGB(255, 228, 98, 18),
            backgroundColor: Color.fromARGB(255, 250, 221, 194),
          ),
        ],
      ),
    );
  }
}
