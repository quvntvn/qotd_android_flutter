import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:intl/intl.dart';
import '../quote_service.dart';
import '../weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Quote? _quote, _daily;
  bool _loading = true;
  late Future<Weather> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = WeatherService.current();
    _loadDaily();
  }

  Future<void> _loadDaily() async {
    setState(() => _loading = true);
    final q = await QuoteService.daily();
    setState(() {
      _quote = q;
      _daily = q;
      _loading = false;
    });
  }

  Future<void> _loadRandom() async {
    setState(() => _loading = true);
    final q = await QuoteService.random();
    setState(() {
      _quote = q;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quote;
    final now = DateFormat.Hm().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Citation du jour'),
        actions: [
          Hero(
            tag: 'settings',
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
        ],
      ),
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _loading
              ? const CircularProgressIndicator(key: ValueKey('loader'))
              : Column(
                  key: ValueKey(quote!.id),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<Weather>(
                      future: _weatherFuture,
                      builder: (ctx, snap) {
                        if (!snap.hasData) return const SizedBox.shrink();
                        final w = snap.data!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            '${w.city} • ${w.temp.toStringAsFixed(1)}°C • $now',
                            style: Theme.of(ctx).textTheme.bodyMedium,
                          ),
                        );
                      },
                    ),
                    QuoteCard(quote: quote),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nouvelle citation',
        onPressed: _loadRandom,
        child: const Icon(Icons.casino),
      ),
      bottomNavigationBar: _quote != null && _quote!.id != _daily?.id
          ? Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextButton(
                onPressed: _loadDaily,
                child: const Text('Revenir à la citation du jour'),
              ),
            )
          : null,
    );
  }
}

class QuoteCard extends StatelessWidget {
  final Quote quote;
  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final year = quote.dateCreation != null
        ? (DateTime.tryParse(quote.dateCreation!)?.year.toString() ??
            'Date inconnue')
        : 'Date inconnue';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText('“${quote.citation}”',
                    textAlign: TextAlign.center,
                    speed: const Duration(milliseconds: 25),
                    textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontStyle: FontStyle.italic,
                        )),
              ],
              isRepeatingAnimation: false,
            ),
            const SizedBox(height: 20),
            Text('— ${quote.auteur}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(year, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
