import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Find Text Demo',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Find Text Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text(
                'Find and highlight text',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _findAndHighLightText,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Find text in specific page',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _findTextInSpecificPage,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Find text in specific range of pages',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _findTextInSpecificRangeOfPages,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Search options',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _searchOptions,
              color: Colors.blue,
            ),
            FlatButton(
              child: Text(
                'Multi search',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _multiSearch,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _findAndHighLightText() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Find text from the PDF document
    List<MatchedItem> findResult = extractor.findText(['PDF']);

    if (findResult.length == 0) {
      document.dispose();
      _showResult('The text is not found');
    } else {
      //Highlight the searched text from the document.
      for (int i = 0; i < findResult.length; i++) {
        MatchedItem item = findResult[i];
        //Get page.
        PdfPage page = document.pages[item.pageIndex];
        //Set transparency to the page graphics.
        page.graphics.save();
        page.graphics.setTransparency(0.5);
        //Draw rectangle to highlight the text.
        page.graphics
            .drawRectangle(bounds: item.bounds, brush: PdfBrushes.yellow);
        page.graphics.restore();
      }

      //Save and launch the document
      final List<int> bytes = document.save();
      //Dispose the document.
      document.dispose();
      //Get the storage folder location using path_provider package.
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = directory.path;
      final File file = File('$path/output.pdf');
      await file.writeAsBytes(bytes);
      //Launch the file (used open_file package)
      await OpenFile.open('$path/output.pdf');
    }
  }

  Future<void> _findTextInSpecificPage() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Find text from the PDF document with specific page
    List<MatchedItem> findResult =
        extractor.findText(['PDF'], startPageIndex: 0);
    if (findResult.length == 0) {
      document.dispose();
      _showResult('The text is not found');
    } else {
      _showResult(findResult.length.toString() + ' matches found.');
    }
  }

  Future<void> _findTextInSpecificRangeOfPages() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Find text from the PDF document with specific range of pages
    List<MatchedItem> findResult =
        extractor.findText(['PDF'], startPageIndex: 1, endPageIndex: 3);
    if (findResult.length == 0) {
      document.dispose();
      _showResult('The text is not found');
    } else {
      _showResult(findResult.length.toString() + ' matches found.');
    }
  }

  Future<void> _searchOptions() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Find text with text search option.
    List<MatchedItem> findResult = extractor.findText(['PDF'],
        startPageIndex: 1,
        endPageIndex: 3,
        searchOption: TextSearchOption.caseSensitive);
    if (findResult.length == 0) {
      document.dispose();
      _showResult('The text is not found');
    } else {
      _showResult(findResult.length.toString() + ' matches found.');
    }
  }

  Future<void> _multiSearch() async {
    //Load the existing PDF document.
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData('pdf_succinctly.pdf'));

    //Create the new instance of the PdfTextExtractor.
    PdfTextExtractor extractor = PdfTextExtractor(document);

    //Find more than one text on the same time.
    List<MatchedItem> findResult = extractor.findText(['PDF', 'document']);
    if (findResult.length == 0) {
      document.dispose();
      _showResult('The text is not found');
    } else {
      _showResult(findResult.length.toString() + ' matches found.');
    }
  }

  Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load('assets/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  void _showResult(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Find Text'),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: Text(text),
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
              ),
            ),
            actions: [
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
