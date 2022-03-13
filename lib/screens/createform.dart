import 'package:flutter/material.dart';

import '../deserialization_classes.dart';

class CreateForm extends StatefulWidget {
  final List<Channel> channels;

  const CreateForm(this.channels, {required Key key}) : super(key: key);
  @override
  _CreateForm createState() => _CreateForm();
}

class _CreateForm extends State<CreateForm> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  Channel? _selectedChannel;
  double _squadSize = 4;

  @override
  void initState() {
    print(widget.channels[0].server.name);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Session'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: _buildCreateForm(),
      ),
    );
  }

  Widget _buildCreateForm() {
    final channelItems = widget.channels
        .map<DropdownMenuItem<Channel>>((e) => DropdownMenuItem(
            child: Text.rich(
              TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: e.channel.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: '\non ${e.server.name}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            value: e))
        .toList();

    return Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Channel'),
            DropdownButtonFormField(
                hint: const Text("Select a Channel"),
                items: channelItems,
                onChanged: ((selected) {
                  setState(() {
                    _selectedChannel = selected as Channel?;
                  });
                })),
            const SizedBox(
              height: 30,
            ),
            Text('Squad size'),
            Slider(
              max: 10,
              divisions: 10,
              label: _squadSize.round().toString(),
              value: _squadSize,
              onChanged: (double value) {
                setState(() {
                  _squadSize = value;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                print('create clicked');
              },
              child: const Text('Create Session'),
            )
          ],
        ),
      ),
    );
  }
}
