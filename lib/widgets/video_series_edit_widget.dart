// Stateful widget to show or hide series information when editing a video
import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reference_library/providers/data_provider.dart';

class VideoSeriesData {
  bool isSeries = false;
  String seriesName = "";
  int seriesPosition = -1;

  VideoSeriesData(this.isSeries, this.seriesName, this.seriesPosition);

  @override
  String toString() {
    return "Series: ${isSeries.toString()} | Name: $seriesName | Pos: ${seriesPosition.toString()}";
  }
}

// ignore: must_be_immutable
class VideoSeriesEditWidget extends StatefulWidget {
  VideoSeriesEditWidget({
    Key? key,
    required this.seriesData,
  }) : super(key: key);
  VideoSeriesData seriesData;

  @override
  State<VideoSeriesEditWidget> createState() => _VideoSeriesEditWidgetState();
}

class _VideoSeriesEditWidgetState extends State<VideoSeriesEditWidget> {
  late String selectedSeries;
  TextEditingController indexController = TextEditingController();

  @override
  void initState() {
    if (widget.seriesData.isSeries) {
      selectedSeries = widget.seriesData.seriesName;
      indexController.text = widget.seriesData.seriesPosition.toString();
    } else {
      selectedSeries = context.read<DataProvider>().series[0];
      indexController.text = "-1";
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text("Series: "),
            ToggleSwitch(
                checked: widget.seriesData.isSeries,
                onChanged: (v) {
                  setState(() {
                    widget.seriesData.isSeries = v;
                  });
                })
          ],
        ),
        Visibility(
            visible: widget.seriesData.isSeries,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(FluentIcons.charticulator_line_style_dashed),
                      const Text("  Series: "),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Combobox<String>(
                          value: selectedSeries,
                          onChanged: (s) => setState(() => selectedSeries = s!),
                          isExpanded: true,
                          items: context
                              .read<DataProvider>()
                              .series
                              .map((e) => ComboboxItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26.5, 0, 0, 0),
                    child: Row(
                      children: [
                        const Text("Position: "),
                        SizedBox(
                          width: 50,
                          child: TextBox(
                            // Make it so only numbers are allowed
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                int? a = int.tryParse(value);
                                if (a != null) {
                                  widget.seriesData.seriesPosition = a;
                                } else {
                                  widget.seriesData.seriesPosition = 0;
                                }
                              } else {
                                widget.seriesData.seriesPosition = 0;
                              }
                            },
                            controller: indexController,
                            keyboardType: TextInputType.number,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ))
      ],
    );
  }
}
