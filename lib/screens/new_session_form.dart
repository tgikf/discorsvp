import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../dto.dart';

class CreateForm extends StatefulWidget {
  final List<Channel> channels;
  final Socket _socket;

  const CreateForm(this.channels, this._socket, {required Key key})
      : super(key: key);
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
            const Text('Channel'),
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
            const Text('Squad size'),
            Slider(
              min: 2,
              max: 10,
              divisions: 8,
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
              onPressed: _selectedChannel != null && _squadSize > 1
                  ? () {
                      print('create clicked ${_squadSize} ${_selectedChannel}');
                      widget._socket.emitWithAck('CreateSession', _squadSize,
                          ack: (data) {
                        print('Acknowledged: $data');
                      });
                    }
                  : null,
              child: const Text('Create Session'),
            )
          ],
        ),
      ),
    );
  }
}
