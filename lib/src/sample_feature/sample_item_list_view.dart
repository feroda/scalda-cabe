import 'package:flutter/material.dart';
import 'package:scalda_cabe/src/settings/settings_controller.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:telephony/telephony.dart';

void mySendSMS(String msg, String recipient) async {
  String sendResult = await sendSMS(message: msg, recipients: [recipient]);
  debugPrint(sendResult);
}

backgrounMessageHandler(SmsMessage message) async {
  debugPrint(message.body.toString());
}

/// Displays a list of SampleItems.
class SampleItemListView extends StatefulWidget {
  const SampleItemListView({
    super.key,
    required this.controller,
    this.items = const [
      SampleItem("#STATO?", "Come sta la casa?"),
      SampleItem("#MAN=20.5", "Set temperatura a 20.5C"),
      SampleItem("#MAN=08.5", "Set temperatura a 08.5C"),
    ],
  });

  static const routeName = '/';

  final List<SampleItem> items;
  final SettingsController controller;

  @override
  State<SampleItemListView> createState() => _SampleItemListViewState();
}

class _SampleItemListViewState extends State<SampleItemListView> {
  String sms = "";
  Telephony telephony = Telephony.instance;

  @override
  void initState() {
    telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          debugPrint(message.address); //+977981******67, sender nubmer
          debugPrint(message.body); //sms text
          setState(() {
            sms = message.body.toString();
          });
        },
        onBackgroundMessage: backgrounMessageHandler);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parla col termostato'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'opsListView',
              itemCount: widget.items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = widget.items[index];

                return ListTile(
                    title: Text(item.description),
                    leading: const CircleAvatar(
                      // Display the Flutter Logo image asset.
                      foregroundImage:
                          AssetImage('assets/images/flutter_logo.png'),
                    ),
                    onTap: () {
                      mySendSMS(item.command, widget.controller.recipient);
                      // Navigate to the details page. If the user leaves and returns to
                      // the app after it has been killed while running in the
                      // background, the navigation stack is restored.
                      /* Navigator.restorablePushNamed(
                  context,
                  SampleItemDetailsView.routeName,
                );*/
                    });
              },
            ),
          ),
          Container(
              height: 400,
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              alignment: Alignment.topLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Il termostato dice...",
                      style: TextStyle(fontSize: 20),
                    ),
                    const Divider(),
                    Text(
                      sms,
                      style: const TextStyle(fontSize: 30),
                    )
                  ])),
        ],
      ),
    );
  }
}
