import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:equatable/equatable.dart';

enum FileProcessStatus { idle, uploading, completed, failed }

class FileProcessState extends Equatable {
  final FileProcessStatus status;
  final String? mean;
  final String? variance;
  final String? secondMoment;
  final String? thirdMoment;
  final String? error;
  final String? pdfImagePath;
  final String? cdfImagePath;
  final String? mgfImagePath;
  final String? mgfPrimeImagePath;
  final String? mgfDoublePrimeImagePath;
  final String? meanX;
  final String? meanY;
  final String? meanZ;
  final String? meanW;
  final String? varianceX;
  final String? varianceY;
  final String? plot2DImagePath;
  final String? plot3DImagePath;
  final String? mariginalXImagePath;
  final String? mariginalYImagePath;
  final String? zdistImagePath;
  final String? wdistImagePath;
  final String? jointImagePath;
  final String? correlation;
  final String? covariance;

  const FileProcessState({
    this.status = FileProcessStatus.idle,
    this.mean,
    this.variance,
    this.secondMoment,
    this.thirdMoment,
    this.error,
    this.pdfImagePath,
    this.cdfImagePath,
    this.mgfImagePath,
    this.mgfPrimeImagePath,
    this.mgfDoublePrimeImagePath,
    this.meanX,
    this.meanY,
    this.meanZ,
    this.meanW,
    this.varianceX,
    this.varianceY,
    this.plot2DImagePath,
    this.plot3DImagePath,
    this.mariginalXImagePath,
    this.mariginalYImagePath,
    this.zdistImagePath,
    this.wdistImagePath,
    this.jointImagePath,
    this.correlation,
    this.covariance,
  });

  // Copy with method for immutability
  FileProcessState copyWith({
    FileProcessStatus? status,
    String? mean,
    String? variance,
    String? secondMoment,
    String? thirdMoment,
    String? error,
    String? pdfImagePath,
    String? cdfImagePath,
    String? mgfImagePath,
    String? mgfPrimeImagePath,
    String? mgfDoublePrimeImagePath,
    String? meanX,
    String? meanY,
    String? meanZ,
    String? meanW,
    String? varianceX,
    String? varianceY,
    String? plot2DImagePath,
    String? plot3DImagePath,
    String? mariginalXImagePath,
    String? mariginalYImagePath,
    String? zdistImagePath,
    String? wdistImagePath,
    String? jointImagePath,
    String? correlation,
    String? covariance,
  }) {
    return FileProcessState(
        status: status ?? this.status,
        mean: mean ?? this.mean,
        variance: variance ?? this.variance,
        secondMoment: secondMoment ?? this.secondMoment,
        thirdMoment: thirdMoment ?? this.thirdMoment,
        error: error ?? this.error,
        pdfImagePath: pdfImagePath ?? this.pdfImagePath,
        cdfImagePath: cdfImagePath ?? this.cdfImagePath,
        mgfImagePath: mgfImagePath ?? this.mgfImagePath,
        mgfPrimeImagePath: mgfPrimeImagePath ?? this.mgfPrimeImagePath,
        mgfDoublePrimeImagePath:
            mgfDoublePrimeImagePath ?? this.mgfDoublePrimeImagePath,
        meanX: meanX ?? this.meanX,
        meanY: meanY ?? this.meanY,
        meanZ: meanZ ?? this.meanZ,
        meanW: meanW ?? this.meanW,
        varianceX: varianceX ?? this.varianceX,
        varianceY: varianceY ?? this.varianceY,
        plot2DImagePath: plot2DImagePath ?? this.plot2DImagePath,
        plot3DImagePath: plot3DImagePath ?? this.plot3DImagePath,
        mariginalXImagePath: mariginalXImagePath ?? this.mariginalXImagePath,
        mariginalYImagePath: mariginalYImagePath ?? this.mariginalYImagePath,
        zdistImagePath: zdistImagePath ?? this.zdistImagePath,
        wdistImagePath: wdistImagePath ?? this.wdistImagePath,
        jointImagePath: jointImagePath ?? jointImagePath,
        correlation: correlation ?? this.correlation,
        covariance: covariance ?? this.covariance);
  }

  @override
  List<Object?> get props => [
        status,
        mean,
        variance,
        secondMoment,
        thirdMoment,
        error,
        pdfImagePath,
        cdfImagePath,
        mgfImagePath,
        mgfPrimeImagePath,
        mgfDoublePrimeImagePath,
        meanX,
        meanY,
        meanZ,
        meanW,
        varianceX,
        varianceY,
        plot2DImagePath,
        plot3DImagePath,
        mariginalXImagePath,
        mariginalYImagePath,
        zdistImagePath,
        wdistImagePath,
        jointImagePath,
        correlation,
        covariance,
      ];
}

class FileProcessCubit extends Cubit<FileProcessState> {
  FileProcessCubit({this.selectedIndex = 0}) : super(const FileProcessState());

  final String serverBaseUrl =
      'https://kit-trusted-silkworm.ngrok-free.app/upload';
  int selectedIndex;

  Future<void> uploadFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        if (selectedIndex == 0) {
          Map<String, String>? inputs;
          if (context.mounted) {
            inputs = await _showInputDialog(context, selectedIndex);
            if (inputs == null) {
              emit(state.copyWith(
                status: FileProcessStatus.idle,
                error: 'Upload canceled by user',
              ));
              return;
            }
            emit(state.copyWith(status: FileProcessStatus.uploading));
          }
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(serverBaseUrl),
          );
          request.files
              .add(await http.MultipartFile.fromPath('file', file.path));
          request.fields['index'] = selectedIndex.toString();
          request.fields['T Range'] = (inputs!['T Range'])!;
          request.fields['Number of Bins'] = (inputs['Number of Bins'])!;
          var response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final data = json.decode(responseBody);
            String mean = (data['Mean']?.toStringAsFixed(2)) ?? 'N/A';
            String variance = (data['Variance']?.toStringAsFixed(2)) ?? 'N/A';
            String thirdMoment =
                (data['ThirdMoment']?.toStringAsFixed(2)) ?? 'N/A';
            final pdfImagePath =
                await _downloadAndSaveImage(data['PDF'], 'pdf_image.png');
            final cdfImagePath =
                await _downloadAndSaveImage(data['CDF'], 'cdf_image.png');
            final mgfImagePath =
                await _downloadAndSaveImage(data['MGF'], 'mgf_plot.png');
            final mgfPrimeImagePath = await _downloadAndSaveImage(
                data['MGF Prime'], 'mgf_prime_plot.png');
            final mgfDoublePrimeImagePath = await _downloadAndSaveImage(
                data['MGF Double Prime'], 'mgf_doubleprime_plot.png');
            emit(state.copyWith(
                status: FileProcessStatus.completed,
                mean: mean,
                variance: variance,
                thirdMoment: thirdMoment,
                pdfImagePath: pdfImagePath,
                cdfImagePath: cdfImagePath,
                mgfImagePath: mgfImagePath,
                mgfPrimeImagePath: mgfPrimeImagePath,
                mgfDoublePrimeImagePath: mgfDoublePrimeImagePath));
          } else {
            emit(state.copyWith(
              status: FileProcessStatus.failed,
              error: 'Server error: ${response.statusCode}',
            ));
          }
        } else if (selectedIndex == 1) {
          Map<String, String>? inputs;
          if (context.mounted) {
            inputs = await _showInputDialog(context, selectedIndex);
            if (inputs == null) {
              emit(state.copyWith(
                status: FileProcessStatus.idle,
                error: 'Upload canceled by user',
              ));
              return;
            }
            emit(state.copyWith(status: FileProcessStatus.uploading));
          }
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(serverBaseUrl),
          );
          request.files
              .add(await http.MultipartFile.fromPath('file', file.path));
          request.fields['index'] = selectedIndex.toString();
          request.fields['Number of Bins'] = (inputs!['Number of Bins'])!;
          var response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final data = json.decode(responseBody);
            final meanX = data['Mean X'].toStringAsFixed(2);
            final varianceX = data['Variance X'].toStringAsFixed(2);
            final meanY = data['Mean Y'].toStringAsFixed(2);
            final varianceY = data['Variance Y'].toStringAsFixed(2);
            final covariance = data['Covariance'].toStringAsFixed(10);
            final correlation = data['Correlation'].toStringAsFixed(10);
            final plot2dImage = await _downloadAndSaveImage(
                data['2D distribution'], 'plot2d_image.png');
            final plot3dImage = await _downloadAndSaveImage(
                data['3D distribution'], 'plot3d_image.png');
            final mariginalXImage = await _downloadAndSaveImage(
                data['mariginal X'], 'mariginalX_image.png');
            final mariginalYImage = await _downloadAndSaveImage(
                data['mariginal Y'], 'mariginalY_image.png');
            emit(state.copyWith(
                status: FileProcessStatus.completed,
                meanX: meanX.toString(),
                meanY: meanY.toString(),
                varianceX: varianceX.toString(),
                varianceY: varianceY.toString(),
                covariance: covariance.toString(),
                correlation: correlation.toString(),
                plot2DImagePath: plot2dImage,
                plot3DImagePath: plot3dImage,
                mariginalXImagePath: mariginalXImage,
                mariginalYImagePath: mariginalYImage));
          } else {
            emit(state.copyWith(
              status: FileProcessStatus.failed,
              error: 'Server error: ${response.statusCode}',
            ));
          }
        } else if (selectedIndex == 2) {
          Map<String, String>? inputs;
          if (context.mounted) {
            inputs = await _showInputDialog(context, selectedIndex);
            if (inputs == null) {
              emit(state.copyWith(
                status: FileProcessStatus.idle,
                error: 'Upload canceled by user',
              ));
              return;
            }
            emit(state.copyWith(status: FileProcessStatus.uploading));
          }
          var request = http.MultipartRequest(
            'POST',
            Uri.parse(serverBaseUrl),
          );
          request.files
              .add(await http.MultipartFile.fromPath('file', file.path));
          request.fields['index'] = selectedIndex.toString();
          request.fields['Number of Bins'] = (inputs!['Number of Bins'])!;
          request.fields['TransZ'] = (inputs['TransZ'])!;
          request.fields['TransW'] = (inputs['TransW'])!;

          var response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final data = json.decode(responseBody);
            final meanX = data['Mean X'].toStringAsFixed(2);
            final meanZ = data['Mean Z'].toStringAsFixed(2);
            final meanY = data['Mean Y'].toStringAsFixed(2);
            final meanW = data['Mean W'].toStringAsFixed(2);
            final covariance = data['Covariance'];
            final correlation = data['Correlation'];

            final zdistImage = await _downloadAndSaveImage(
                data['Z distribution'], 'Z_dist_plot.png');
            final wdistImage = await _downloadAndSaveImage(
                data['W distribution'], 'W_dist_plot.png');
            final jointImage =
                await _downloadAndSaveImage(data['Joint'], 'joint_plot.png');
            emit(state.copyWith(
                status: FileProcessStatus.completed,
                meanX: meanX.toString(),
                meanZ: meanZ.toString(),
                meanY: meanY.toString(),
                meanW: meanW.toString(),
                covariance: covariance.toString(),
                correlation: correlation.toString(),
                zdistImagePath: zdistImage,
                wdistImagePath: wdistImage,
                jointImagePath: jointImage));
          } else {
            emit(state.copyWith(
              status: FileProcessStatus.failed,
              error: 'Server error: ${response.statusCode}',
            ));
          }
        }
      } else {
        emit(state.copyWith(
          status: FileProcessStatus.failed,
          error: 'No file selected',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: FileProcessStatus.failed,
        error: 'Error: $e',
      ));
    }
  }

  Future<Map<String, String>?> _showInputDialog(
      BuildContext context, int index) async {
    TextEditingController field1Controller = TextEditingController();
    TextEditingController field2Controller = TextEditingController();
    TextEditingController field3Controller = TextEditingController();

    if (index == 0) {
      return showDialog<Map<String, String>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Additional Inputs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: field1Controller,
                decoration: const InputDecoration(labelText: 'T range'),
              ),
              TextField(
                controller: field2Controller,
                decoration: const InputDecoration(labelText: 'Number of Bins'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'T Range': field1Controller.text,
                  'Number of Bins': field2Controller.text,
                });
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } else if (index == 1) {
      return showDialog<Map<String, String>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Additional Inputs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: field2Controller,
                decoration: const InputDecoration(labelText: 'Number of Bins'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'Number of Bins': field2Controller.text,
                });
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } else if (index == 2) {
      return showDialog<Map<String, String>>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Additional Inputs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: field2Controller,
                decoration: const InputDecoration(labelText: 'Number of Bins'),
              ),
              TextField(
                controller: field1Controller,
                decoration:
                    const InputDecoration(labelText: 'Transformation Z'),
              ),
              TextField(
                controller: field3Controller,
                decoration:
                    const InputDecoration(labelText: 'Transformation W'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'Number of Bins': field2Controller.text,
                  'TransZ': field1Controller.text,
                  'TransW': field3Controller.text
                });
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    }
    return null;
  }

  Future<String> _downloadAndSaveImage(String url, String fileName) async {
    final directory = Directory.systemTemp;
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  void reset() => emit(const FileProcessState());
}
