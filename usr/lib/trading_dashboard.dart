import 'package:flutter/material.dart';
import 'dart:async';

class TradingDashboard extends StatefulWidget {
  const TradingDashboard({super.key});

  @override
  State<TradingDashboard> createState() => _TradingDashboardState();
}

class _TradingDashboardState extends State<TradingDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Form Controllers
  final TextEditingController _symbolController = TextEditingController(text: 'SBIN-EQ');
  final TextEditingController _tokenController = TextEditingController(text: '3045');
  final TextEditingController _webhookUrlController = TextEditingController(text: 'http://10.0.2.2:5000/webhook');
  
  // State
  String _selectedExchange = 'NSE';
  String _selectedAction = 'BUY';
  bool _isLoading = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _addLog("System initialized. Ready to connect to Trading Bot.");
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symbolController.dispose();
    _tokenController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, "[${DateTime.now().toString().split('.').first}] $message");
    });
  }

  Future<void> _executeWebhook() async {
    setState(() {
      _isLoading = true;
    });

    _addLog("Initiating $_selectedAction for $_selectedExchange: ${_symbolController.text}...");

    // Simulate Network Delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock Response Logic (Since we don't have a real backend running yet)
    // In a real app, this would use http.post() to the Python Flask server
    
    bool success = true; // Simulate success
    
    if (success) {
      _addLog("✅ Webhook sent successfully to ${_webhookUrlController.text}");
      _addLog("ℹ️ Closing existing positions for ${_symbolController.text}...");
      await Future.delayed(const Duration(seconds: 1));
      _addLog("✅ Position Closed.");
      _addLog("🚀 Placed new $_selectedAction order for ${_symbolController.text}.");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade Executed Successfully'), backgroundColor: Colors.green),
        );
      }
    } else {
      _addLog("❌ Error: Failed to connect to webhook.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trade Failed'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Angel One Bot Controller'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.candlestick_chart), text: 'Trade'),
            Tab(icon: Icon(Icons.terminal), text: 'Logs'),
            Tab(icon: Icon(Icons.settings), text: 'Config'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTradeTab(),
          _buildLogsTab(),
          _buildConfigTab(),
        ],
      ),
    );
  }

  Widget _buildTradeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Signal Configuration",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedExchange,
                    decoration: const InputDecoration(
                      labelText: 'Exchange',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    items: ['NSE', 'MCX'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _selectedExchange = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _symbolController,
                    decoration: const InputDecoration(
                      labelText: 'Trading Symbol',
                      hintText: 'e.g., SBIN-EQ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.abc),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tokenController,
                    decoration: const InputDecoration(
                      labelText: 'Symbol Token',
                      hintText: 'e.g., 3045',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Action",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'BUY',
                        label: Text('BUY'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment(
                        value: 'SELL',
                        label: Text('SELL'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                    selected: {_selectedAction},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedAction = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return _selectedAction == 'BUY' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2);
                        }
                        return Colors.transparent;
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return _selectedAction == 'BUY' ? Colors.green : Colors.red;
                        }
                        return Colors.white;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _executeWebhook,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedAction == 'BUY' ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Icon(Icons.bolt),
              label: Text(
                _isLoading ? "PROCESSING..." : "EXECUTE ${_selectedAction} ORDER",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(8.0),
      child: _logs.isEmpty
          ? const Center(child: Text("No logs yet.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                Color logColor = Colors.greenAccent;
                if (log.contains("Error") || log.contains("Failed")) logColor = Colors.redAccent;
                if (log.contains("Closing")) logColor = Colors.orangeAccent;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    log,
                    style: TextStyle(color: logColor, fontFamily: 'Courier'),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildConfigTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Backend Configuration", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  "The Python script you provided acts as the backend server. "
                  "Ensure your Flask app is running and accessible from this device.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _webhookUrlController,
          decoration: const InputDecoration(
            labelText: 'Webhook URL',
            hintText: 'http://YOUR_IP:5000/webhook',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
        ),
        const SizedBox(height: 16),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text("Localhost Note"),
          subtitle: Text("If running on Android Emulator, use http://10.0.2.2:5000 instead of localhost."),
        ),
      ],
    );
  }
}
