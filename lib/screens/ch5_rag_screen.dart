import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/rag_provider.dart';

class RAGScreen extends ConsumerStatefulWidget {
  const RAGScreen({super.key});

  @override
  ConsumerState<RAGScreen> createState() => _RAGScreenState();
}

class _RAGScreenState extends ConsumerState<RAGScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    ref.read(ragProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final ragState = ref.watch(ragProvider);
    final notifier = ref.read(ragProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RAG for Flutter'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              notifier.clearSearch();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'เอกสารฐานความรู้:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: notifier.documents
                  .map(
                    (doc) => Chip(
                      label: Text(
                        doc.substring(0, doc.length > 20 ? 20 : doc.length),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'พิมพ์คำถามของคุณ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: const Icon(Icons.search),
              ),
              maxLines: 2,
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: ragState.isLoading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('ค้นหา'),
              ),
            ),
            const SizedBox(height: 32),
            if (ragState.isLoading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text('กำลังค้นหา...'),
                  ],
                ),
              )
            else if (ragState.answer.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'คำถาม:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ragState.query,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'เอกสารที่เกี่ยวข้อง:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...ragState.retrievedDocs.map((doc) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.description,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              doc,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'คำตอบ:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ragState.answer,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              )
            else if (ragState.query.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ถามคำถามเกี่ยวกับ Flutter ได้เลย!',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
