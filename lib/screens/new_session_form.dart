import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:overlay_support/overlay_support.dart';

import '../common/dto.dart';

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
                isDense: false,
                isExpanded: true,
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
            Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  child: Column(
                    children: const [
                      ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Channel Selection'),
                          subtitle: Text(
                              'For its channels to be available, a Discord server must be onboarded to DiscoRSVP.')),
                      Divider(
                        indent: 16,
                        endIndent: 16,
                      ),
                      ListTile(
                        leading: Icon(Icons.admin_panel_settings_outlined),
                        title: Text('User Permissions'),
                        subtitle: Text(
                            'To join your session, all squad members need the respective privileges on the Discord server of your chosen channel.'),
                      )
                    ],
                  )),
            ),
            const SizedBox(
              height: 30,
            ),
            OutlinedButton(
              onPressed: _selectedChannel != null && _squadSize > 1
                  ? () {
                      Map<String, dynamic> sessionRequest = {};
                      sessionRequest.addAll(
                          {'channel': _selectedChannel, 'target': _squadSize});
                      widget._socket.emitWithAck(
                          'CreateSession', sessionRequest, ack: (data) {
                        Map<String, dynamic> res = jsonDecode(data);
                        final String msg = res['success']
                            ? 'Session created!'
                            : res['message'];

                        final Icon icn = Icon(
                            res['success'] ? Icons.done : Icons.error,
                            color: Theme.of(context).colorScheme.onPrimary);
                        showSimpleNotification(Text(msg),
                            leading: icn,
                            background: Theme.of(context).colorScheme.primary,
                            foreground:
                                Theme.of(context).colorScheme.onPrimary);

                        if (res['success']) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  : null,
              child: const Text('Create'),
            )
          ],
        ),
      ),
    );
  }
}
