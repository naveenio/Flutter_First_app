class PortModel {
  final int port;
  final String speed;
  final String duplex;
  final String flowControl;
  final int linkStatus;

  PortModel({
    required this.port,
    required this.speed,
    required this.duplex,
    required this.flowControl,
    required this.linkStatus,
  });

  factory PortModel.fromJson(Map<String, dynamic> json) {
    return PortModel(
      port: json['port'],
      speed: json['speed'],
      duplex: json['duplex'],
      flowControl: json['flowControl'],
      linkStatus: json['link_status'],
    );
  }
}
