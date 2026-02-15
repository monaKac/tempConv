import 'package:flutter/material.dart';
import 'package:grpc/grpc_web.dart';
import 'proto/temperature.pbgrpc.dart';

void main() => runApp(const TempConvApp());

class TempConvApp extends StatelessWidget {
  const TempConvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ConverterPage(),
    );
  }
}

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _controller = TextEditingController();
  String _result = '';
  bool _celsiusToFahrenheit = true;
  bool _loading = false;

  // Connect to Envoy proxy via gRPC-Web.
  // In production the URI comes from the browser's current origin;
  // during local Docker Compose testing Envoy listens on port 8080.
  late final _channel = GrpcWebClientChannel.xhr(
    Uri.parse('http://localhost:8080'),
  );
  late final _client = TemperatureConverterClient(_channel);

  Future<void> _convert() async {
    final input = double.tryParse(_controller.text);
    if (input == null) {
      setState(() => _result = 'Please enter a valid number.');
      return;
    }

    setState(() => _loading = true);
    try {
      if (_celsiusToFahrenheit) {
        final resp = await _client.celsiusToFahrenheit(
          CelsiusRequest()..celsius = input,
        );
        setState(() => _result =
            '${input.toStringAsFixed(2)} °C = ${resp.fahrenheit.toStringAsFixed(2)} °F');
      } else {
        final resp = await _client.fahrenheitToCelsius(
          FahrenheitRequest()..fahrenheit = input,
        );
        setState(() => _result =
            '${input.toStringAsFixed(2)} °F = ${resp.celsius.toStringAsFixed(2)} °C');
      }
    } catch (e) {
      setState(() => _result = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.shutdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temperature Converter')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('°C → °F')),
                    ButtonSegment(value: false, label: Text('°F → °C')),
                  ],
                  selected: {_celsiusToFahrenheit},
                  onSelectionChanged: (v) =>
                      setState(() => _celsiusToFahrenheit = v.first),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    labelText: _celsiusToFahrenheit
                        ? 'Degrees Celsius'
                        : 'Degrees Fahrenheit',
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _convert(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _convert,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Convert'),
                ),
                const SizedBox(height: 24),
                Text(
                  _result,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
