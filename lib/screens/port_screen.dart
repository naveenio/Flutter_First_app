import '../models/port_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PortPage extends StatefulWidget {
  const PortPage({Key? key}) : super(key: key);

  @override
  _PortPageState createState() => _PortPageState();
}

class _PortPageState extends State<PortPage> {
  List<PortModel> ports = [];
  List<PortModel> filteredPorts = [];
  bool isLoading = true;
  String error = '';

  // Filter states
  String? selectedDuplex;
  String? selectedFlowControl;
  int? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchPorts();
  }

  Future<void> fetchPorts() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.npoint.io/36247ccf47693ff2cc4c'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> portsData = data['ports'];

        setState(() {
          ports = portsData.map((port) => PortModel.fromJson(port)).toList();
          applyFilters(); // Apply filters to the new data
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load ports data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredPorts = ports.where((port) {
        bool matchesDuplex =
            selectedDuplex == null || port.duplex == selectedDuplex;
        bool matchesFlowControl = selectedFlowControl == null ||
            port.flowControl == selectedFlowControl;
        bool matchesStatus =
            selectedStatus == null || port.linkStatus == selectedStatus;
        return matchesDuplex && matchesFlowControl && matchesStatus;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Ports'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDuplex,
                      decoration: const InputDecoration(labelText: 'Duplex'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        ...ports
                            .map((p) => p.duplex)
                            .toSet()
                            .map((duplex) => DropdownMenuItem(
                                  value: duplex,
                                  child: Text(duplex ?? 'Unknown'),
                                )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDuplex = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedFlowControl,
                      decoration:
                          const InputDecoration(labelText: 'Flow Control'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All')),
                        ...ports
                            .map((p) => p.flowControl)
                            .toSet()
                            .map((flowControl) => DropdownMenuItem(
                                  value: flowControl,
                                  child: Text(flowControl ?? 'Unknown'),
                                )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFlowControl = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All')),
                        DropdownMenuItem(value: 1, child: Text('Connected')),
                        DropdownMenuItem(value: 0, child: Text('Disconnected')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedDuplex = null;
                      selectedFlowControl = null;
                      selectedStatus = null;
                    });
                  },
                  child: const Text('Clear Filters'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    applyFilters();
                    fetchPorts();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ports Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchPorts();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(child: Text(error))
              : RefreshIndicator(
                  onRefresh: fetchPorts,
                  child: ListView.builder(
                    itemCount: filteredPorts.length,
                    itemBuilder: (context, index) {
                      final port = filteredPorts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: port.linkStatus == 1
                                ? Colors.green
                                : Colors.red,
                            child: Text(
                              port.port.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text('Port ${port.port}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Speed: ${port.speed}'),
                              Text('Duplex: ${port.duplex}'),
                              Text('Flow Control: ${port.flowControl}'),
                              Text(
                                'Status: ${port.linkStatus == 1 ? "Connected" : "Disconnected"}',
                                style: TextStyle(
                                  color: port.linkStatus == 1
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
