import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_iot/wifi_iot.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<WifiNetwork> availableDevices = [];
  String? connectedDevice;

  @override
  void initState() {
    super.initState();
    _loadSavedDevice();
    _scanWifi();
  }

  Future<void> _loadSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      connectedDevice = prefs.getString('connected_device');
    });
  }

  Future<void> _saveConnectedDevice(String ssid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connected_device', ssid);
  }

  Future<void> _disconnectDevice() async {
    await WiFiForIoTPlugin.disconnect();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('connected_device');
    setState(() {
      connectedDevice = null;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Déconnecté de l’appareil')));
  }

  Future<void> _scanWifi() async {
    final list = await WiFiForIoTPlugin.loadWifiList();
    setState(() {
      availableDevices = list;
    });
  }

  Future<void> _connectToDevice(String ssid) async {
    final success = await WiFiForIoTPlugin.connect(
      ssid,
      security: NetworkSecurity.NONE,
    );
    if (success) {
      await _saveConnectedDevice(ssid);
      setState(() {
        connectedDevice = ssid;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connecté à $ssid')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connexion à $ssid échouée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appareils disponibles'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _scanWifi),
        ],
      ),
      body: Column(
        children: [
          if (connectedDevice != null) _buildArroseurStatusCard(),
          Expanded(
            child: availableDevices.isEmpty
                ? const Center(child: Text("Aucun appareil trouvé."))
                : ListView.builder(
                    itemCount: availableDevices.length,
                    itemBuilder: (context, index) {
                      final ap = availableDevices[index];
                      final isConnected = connectedDevice == ap.ssid;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.wifi,
                            color: isConnected ? Colors.green : Colors.grey,
                          ),
                          title: Text(ap.ssid ?? ''),
                          subtitle: Text(
                            isConnected ? 'Connecté' : 'Non connecté',
                          ),
                          trailing: isConnected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.wifi_tethering_off,
                                  color: Colors.red,
                                ),
                          onTap: ap.ssid != null
                              ? () => _connectToDevice(ap.ssid!)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildArroseurStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.green.shade50,
      elevation: 4,
      child: ListTile(
        leading: const Icon(Icons.grass, color: Colors.green, size: 36),
        title: Text(
          'Arroseur connecté : $connectedDevice',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Prêt à être contrôlé à distance'),
        trailing: IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.red),
          onPressed: _disconnectDevice,
          tooltip: 'Déconnecter',
        ),
      ),
    );
  }
}
// This code defines a screen for managing Wi-Fi devices, allowing users to connect to and disconnect from available devices.
// It uses the wifi_iot package to scan for Wi-Fi networks, connect to them, and save the connected device in shared preferences.