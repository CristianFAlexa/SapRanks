import 'package:bored/model/Constants.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGenPage extends StatelessWidget {
  QrCodeGenPage(this.documentId, this.gameName);

  final String documentId;
  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Scan QR Code', style: TextStyle(fontSize: 16,),),
            ),
            QrImage(
              foregroundColor: Constants.primaryColor,
              data: gameName + " " + documentId,
              gapless: true,
              size: 400,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
            InkWell(
              onTap: () => {
                Navigator.of(context).pop(),
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, right: 16, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Icon(Icons.arrow_back),
                    Text('Back to events')
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
