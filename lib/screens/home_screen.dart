import 'package:flutter/material.dart';
import '../quote_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  Quote? _quote, _daily;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citation du jour'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '“${quote!.citation}”',
                    style: const TextStyle(
                        fontSize: 22, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text('— ${quote.auteur}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    quote.dateCreation != null
                        ? (DateTime.tryParse(quote.dateCreation!)
                                ?.year
                                .toString() ??
                            'Date inconnue')
                        : 'Date inconnue',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _loadRandom,
                    child: const Text('Voir une autre citation'),
                  ),
                  if (quote.id != _daily?.id)
                    TextButton(
                        onPressed: _loadDaily,
                        child: const Text('Revenir au jour')),
                ],
              ),
            ),
    );
  }
}
