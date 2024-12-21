import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:iconsax/iconsax.dart';
import 'package:prop/bloc/File%20Uploader/fileprocesscubit.dart';
import 'package:prop/bloc/TabBar/tabcubit.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TabCubit()),
        BlocProvider(create: (_) => FileProcessCubit())
      ],
      child: Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BlocBuilder<TabCubit, int>(
                builder: (context, selectedTabIndex) {
                  return Column(
                    children: [
                      Center(
                        child: TabBar(
                          padding: const EdgeInsets.all(8),
                          tabAlignment: TabAlignment.center,
                          overlayColor:
                              const WidgetStatePropertyAll(Colors.transparent),
                          controller: TabController(
                            length: 3,
                            vsync: Navigator.of(context),
                            initialIndex: selectedTabIndex,
                          ),
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(
                              child: SizedBox(
                                width: Platform.isWindows ? 100 : 80,
                                height: Platform.isWindows ? 100 : 80,
                                child: const Center(child: Text("Section 1")),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: Platform.isWindows ? 100 : 80,
                                height: Platform.isWindows ? 100 : 80,
                                child: const Center(child: Text("Section 2")),
                              ),
                            ),
                            Tab(
                              child: SizedBox(
                                width: Platform.isWindows ? 100 : 80,
                                height: Platform.isWindows ? 100 : 80,
                                child: const Center(child: Text("Section 3")),
                              ),
                            ),
                          ],
                          labelColor: const Color.fromARGB(255, 0, 0, 0),
                          indicator: RectangularIndicator(
                              strokeWidth: 0.5,
                              verticalPadding: 5,
                              bottomLeftRadius: 10,
                              bottomRightRadius: 10,
                              topLeftRadius: 10,
                              topRightRadius: 10,
                              paintingStyle: PaintingStyle.stroke),
                          onTap: (index) {
                            context.read<TabCubit>().selectTab(index);
                            context.read<FileProcessCubit>().selectedIndex =
                                index;
                            context.read<FileProcessCubit>().reset();
                          },
                        ),
                      ),
                      BlocBuilder<FileProcessCubit, FileProcessState>(
                          builder: (context, state) {
                        if (selectedTabIndex == 0) {
                          final status = state.status;
                          final mean = state.mean;
                          final variance = state.variance;
                          final thirdMoment = state.thirdMoment;
                          final pdfImage = state.pdfImagePath;
                          final cdfImage = state.cdfImagePath;
                          final mgfImage = state.mgfImagePath;
                          final mgfPrimeImage = state.mgfPrimeImagePath;
                          final mgfDoublePrimeImage =
                              state.mgfDoublePrimeImagePath;

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (status == FileProcessStatus.idle) ...[
                                  Platform.isWindows
                                      ? fileUploader(() => context
                                          .read<FileProcessCubit>()
                                          .uploadFile(context))
                                      : fileUploaderMobile(
                                          () => context
                                              .read<FileProcessCubit>()
                                              .uploadFile(context),
                                          context)
                                ] else if (status ==
                                    FileProcessStatus.uploading) ...[
                                  const Column(
                                    children: [
                                      SizedBox(
                                        height: 300,
                                      ),
                                      SpinKitPulsingGrid(
                                        color: Colors.black,
                                        boxShape: BoxShape.rectangle,
                                        size: 50,
                                        duration: Duration(seconds: 2),
                                      ),
                                    ],
                                  )
                                ] else if (status ==
                                    FileProcessStatus.completed) ...[
                                  Platform.isWindows
                                      ? section1(
                                          mean!,
                                          variance!,
                                          thirdMoment!,
                                          pdfImage!,
                                          cdfImage!,
                                          mgfImage!,
                                          mgfPrimeImage!,
                                          mgfDoublePrimeImage!)
                                      : section1Mobile(
                                          mean!,
                                          variance!,
                                          thirdMoment!,
                                          pdfImage!,
                                          cdfImage!,
                                          mgfImage!,
                                          mgfPrimeImage!,
                                          mgfDoublePrimeImage!,
                                          context),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => context
                                          .read<FileProcessCubit>()
                                          .reset(),
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            const Color.fromARGB(255, 0, 0, 0)
                                                .withOpacity(0.1)),
                                        side: WidgetStatePropertyAll(BorderSide(
                                            color: const Color.fromARGB(
                                                    255, 0, 0, 0)
                                                .withOpacity(0.5),
                                            width: 1)),
                                      ),
                                      child: const Text(
                                        'Process Another File',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ] else if (status ==
                                    FileProcessStatus.failed) ...[
                                  Text('Failed: ${state.error}'),
                                  ElevatedButton(
                                    onPressed: () => context
                                        .read<FileProcessCubit>()
                                        .reset(),
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        } else if (selectedTabIndex == 1) {
                          final status = state.status;
                          final error = state.error ?? '';
                          final meanX = state.meanX ?? '';
                          final meanY = state.meanY ?? '';
                          final varianceX = state.varianceX ?? '';
                          final varianceY = state.varianceY ?? '';
                          final plot2d = state.plot2DImagePath ?? '';
                          final plot3d = state.plot3DImagePath ?? '';
                          final marginalX = state.mariginalXImagePath ?? '';
                          final marginalY = state.mariginalYImagePath ?? '';
                          final corr = state.correlation ?? '';
                          final cov = state.covariance ?? '';
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (status == FileProcessStatus.idle) ...[
                                  fileUploader(() => context
                                      .read<FileProcessCubit>()
                                      .uploadFile(context))
                                ] else if (status ==
                                    FileProcessStatus.uploading) ...[
                                  const Column(
                                    children: [
                                      SizedBox(
                                        height: 300,
                                      ),
                                      SpinKitPulsingGrid(
                                        color: Colors.black,
                                        boxShape: BoxShape.rectangle,
                                        size: 50,
                                        duration: Duration(seconds: 2),
                                      ),
                                    ],
                                  )
                                ] else if (status ==
                                    FileProcessStatus.completed) ...[
                                  Platform.isWindows
                                      ? section2(
                                          meanX,
                                          varianceX,
                                          meanY,
                                          varianceY,
                                          plot2d,
                                          plot3d,
                                          marginalX,
                                          marginalY)
                                      : section2Mobile(
                                          meanX,
                                          varianceX,
                                          meanY,
                                          varianceY,
                                          corr,
                                          cov,
                                          plot2d,
                                          plot3d,
                                          marginalX,
                                          marginalY,
                                          context),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => context
                                          .read<FileProcessCubit>()
                                          .reset(),
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            const Color.fromARGB(255, 0, 0, 0)
                                                .withOpacity(0.1)),
                                        side: WidgetStatePropertyAll(BorderSide(
                                            color: const Color.fromARGB(
                                                    255, 0, 0, 0)
                                                .withOpacity(0.5),
                                            width: 1)),
                                      ),
                                      child: const Text(
                                        'Process Another File',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ] else if (status ==
                                    FileProcessStatus.failed) ...[
                                  Text('Failed: $error'),
                                  ElevatedButton(
                                    onPressed: () => context
                                        .read<FileProcessCubit>()
                                        .reset(),
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        } else if (selectedTabIndex == 2) {
                          final status = state.status;
                          final error = state.error ?? '';
                          final meanX = state.meanX ?? '';
                          final meanZ = state.meanZ ?? '';
                          final meanY = state.meanY ?? '';
                          final meanW = state.meanW ?? '';
                          final zDist = state.zdistImagePath ?? '';
                          final wDist = state.wdistImagePath ?? '';
                          final joint = state.jointImagePath ?? '';
                          final corr = state.correlation ?? '';
                          final cov = state.covariance ?? '';
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (status == FileProcessStatus.idle) ...[
                                  fileUploader(() => context
                                      .read<FileProcessCubit>()
                                      .uploadFile(context))
                                ] else if (status ==
                                    FileProcessStatus.uploading) ...[
                                  const Column(
                                    children: [
                                      SizedBox(
                                        height: 300,
                                      ),
                                      SpinKitPulsingGrid(
                                        color: Colors.black,
                                        boxShape: BoxShape.rectangle,
                                        size: 50,
                                        duration: Duration(seconds: 2),
                                      ),
                                    ],
                                  )
                                ] else if (status ==
                                    FileProcessStatus.completed) ...[
                                  Platform.isWindows
                                      ? section3(meanX, meanZ, meanY, meanW,
                                          zDist, wDist, joint)
                                      : section3Mobile(
                                          meanX,
                                          meanZ,
                                          meanY,
                                          meanW,
                                          corr,
                                          cov,
                                          zDist,
                                          wDist,
                                          joint,
                                          context),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => context
                                          .read<FileProcessCubit>()
                                          .reset(),
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            const Color.fromARGB(255, 0, 0, 0)
                                                .withOpacity(0.1)),
                                        side: WidgetStatePropertyAll(BorderSide(
                                            color: const Color.fromARGB(
                                                    255, 0, 0, 0)
                                                .withOpacity(0.5),
                                            width: 1)),
                                      ),
                                      child: const Text(
                                        'Process Another File',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )
                                ] else if (status ==
                                    FileProcessStatus.failed) ...[
                                  Text('Failed: $error'),
                                  ElevatedButton(
                                    onPressed: () => context
                                        .read<FileProcessCubit>()
                                        .reset(),
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }
                        return Container();
                      })
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget fileUploader(Function func) {
  return GestureDetector(
    onTap: () async {
      await func();
    },
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          dashPattern: const [20, 4],
          strokeCap: StrokeCap.round,
          color: const Color.fromARGB(255, 44, 53, 61),
          child: Container(
            width: double.infinity,
            height: 600,
            decoration: BoxDecoration(
                color: Colors.black12.withOpacity(.03),
                borderRadius: BorderRadius.circular(10)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.folder_open,
                  color: Colors.black54,
                  size: 40,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Select your file',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),
        )),
  );
}

Widget fileUploaderMobile(Function func, BuildContext context) {
  return GestureDetector(
    onTap: () async {
      await func();
    },
    child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          dashPattern: const [20, 4],
          strokeCap: StrokeCap.round,
          color: const Color.fromARGB(255, 44, 53, 61),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 150,
            decoration: BoxDecoration(
                color: Colors.black12.withOpacity(.03),
                borderRadius: BorderRadius.circular(10)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.folder_open,
                  color: Colors.black54,
                  size: 40,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  'Select your file',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
              ],
            ),
          ),
        )),
  );
}

Widget section1(
    String mean,
    String variance,
    String thirdMoment,
    String pdfImagePath,
    String cdfImagePath,
    String mgfImagePath,
    String mgfPrimeImagePath,
    String mgfDoublePrimeImagePath) {
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 460,
              height: 100,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.file(
                      File("Assets\\Images\\Mean.png"),
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Mean : $mean",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            GlassmorphicContainer(
              width: 470,
              height: 100,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.file(
                      File("Assets\\Images\\Variance.png"),
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Variace : $variance",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            GlassmorphicContainer(
              width: 460,
              height: 100,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.file(
                      File("Assets\\Images\\monitor.png"),
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Third Moment : $thirdMoment",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 710,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "PDF",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(pdfImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 700,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "CDF",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(cdfImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 460,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "MGF",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(mgfImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 470,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "MGF'",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(mgfPrimeImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 460,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "MGF''",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(mgfDoublePrimeImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget section1Mobile(
    String mean,
    String variance,
    String thirdMoment,
    String pdfImagePath,
    String cdfImagePath,
    String mgfImagePath,
    String mgfPrimeImagePath,
    String mgfDoublePrimeImagePath,
    BuildContext context) {
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.1,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 20,
                ),
                Image.asset(
                  'Assets\\Images\\Mean.png',
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Mean : $mean",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 20, 20, 20),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.1,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 20,
                ),
                Image.asset(
                  'Assets\\Images\\Variance.png',
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Variance : $variance",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 20, 20, 20),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.1,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 20,
                ),
                Image.asset(
                  'Assets\\Images\\monitor.png',
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.width * 0.1,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Third Moment : $thirdMoment",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 20, 20, 20),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "PDF",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(pdfImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "CDF",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(cdfImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "MGF",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(mgfImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "MGF'",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(mgfPrimeImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "MGF''",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(mgfDoublePrimeImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Widget section2(
  String meanX,
  String varianceX,
  String meanY,
  String varianceY,
  String plot2dImagePath,
  String plot3dImagePath,
  String mariginalXImagePath,
  String mariginalYImagePath,
) {
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 710,
              height: 300,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "X Analysis",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Image.file(
                        File("Assets\\Images\\Mean.png"),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Mean : $meanX",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 20, 20, 20),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Image.file(
                        File("Assets\\Images\\Variance.png"),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Variance : $varianceX",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 20, 20, 20),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 700,
              height: 300,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Y Analysis",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Image.file(
                        File("Assets\\Images\\Mean.png"),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Mean : $meanY",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 20, 20, 20),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Image.file(
                        File("Assets\\Images\\Variance.png"),
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Mean : $varianceY",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 20, 20, 20),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 710,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "2D Distriution Plot",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(plot2dImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 700,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "3D Distriution Plot",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(plot3dImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 710,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Mariginal X",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(mariginalXImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 700,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Mariginal Y",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(mariginalYImagePath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget section2Mobile(
    String meanX,
    String varianceX,
    String meanY,
    String varianceY,
    String correlation,
    String covariance,
    String plot2dImagePath,
    String plot3dImagePath,
    String mariginalXImagePath,
    String mariginalYImagePath,
    BuildContext context) {
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.3,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "X Analysis",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Image.asset(
                    'Assets\\Images\\Mean.png',
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Mean : $meanX",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Image.asset(
                    'Assets\\Images\\Variance.png',
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Variance : $varianceX",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.3,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Y Analysis",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Image.asset(
                    'Assets\\Images\\Mean.png',
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Mean : $meanY",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Image.asset(
                    'Assets\\Images\\Variance.png',
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Variance : $varianceY",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\covariance.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Covariance: $covariance",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\correlation.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Correlation: $correlation",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "2D Distriution Plot",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(plot2dImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "3D Distriution Plot",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(plot3dImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Mariginal X",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(mariginalXImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Mariginal Y",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(mariginalYImagePath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
      ],
    ),
  );
}

Widget section3(
  String meanX,
  String meanZ,
  String meanY,
  String meanW,
  String zDistPath,
  String wDistPath,
  String jointPath,
) {
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 710,
              height: 150,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Image.file(
                          File("Assets\\Images\\Mean.png"),
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Mean of X: $meanX",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 20, 20, 20),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Image.file(
                          File("Assets\\Images\\Mean.png"),
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Mean of Z: $meanZ",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 20, 20, 20),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            GlassmorphicContainer(
              width: 700,
              height: 150,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Image.file(
                          File("Assets\\Images\\Mean.png"),
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Mean of Y : $meanY",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 20, 20, 20),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        Image.file(
                          File("Assets\\Images\\Mean.png"),
                          width: 50,
                          height: 50,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Mean of W : $meanW",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 20, 20, 20),
                              fontSize: 30,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassmorphicContainer(
              width: 460,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Z Distribution Plot",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(zDistPath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 470,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "W Distribution Plot",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(wDistPath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
            GlassmorphicContainer(
              width: 460,
              height: 500,
              borderRadius: 20,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 2,
              linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                    const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
                  ],
                  stops: const [
                    0.1,
                    1,
                  ]),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
                  const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Joint Plot",
                    style: TextStyle(
                        color: Color.fromARGB(255, 20, 20, 20),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  Image.file(
                    File(jointPath),
                    width: 400,
                    height: 400,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget section3Mobile(
  String meanX,
  String meanZ,
  String meanY,
  String meanW,
  String correlation,
  String covariance,
  String zDistPath,
  String wDistPath,
  String jointPath,
  BuildContext context,
) {
  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\Mean.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Mean of X: $meanX",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\Mean.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Mean of Z: $meanZ",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\Mean.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Mean of Y : $meanY",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\Mean.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Mean of W : $meanW",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\Mean.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Covariance: $covariance",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Image.asset(
                      'Assets\\Images\\Mean.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Correlation: $correlation",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 20, 20, 20),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.45,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Z Distribution Plot",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(zDistPath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.45,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "W Distribution Plot",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(wDistPath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        GlassmorphicContainer(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.45,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                const Color.fromARGB(255, 0, 0, 0).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 3, 3, 3).withOpacity(0.5),
              const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Joint Plot",
                style: TextStyle(
                    color: Color.fromARGB(255, 20, 20, 20),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Image.file(
                File(jointPath),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
              )
            ],
          ),
        ),
      ],
    ),
  );
}
