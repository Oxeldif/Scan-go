import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../repositories/product_repository.dart';
import '../services/mock_computer_vision_service.dart';

class CvDebugPanel extends StatelessWidget {
  final MockComputerVisionService cvService;

  const CvDebugPanel({
    super.key,
    required this.cvService,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade400, width: 1.5),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: const Icon(Icons.sensors, color: Colors.amber),
        title: const Text(
          'Computer Vision Simulator (Debug Mode Only)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.amber,
          ),
        ),
        subtitle: const Text(
          'Simulate physical cart computer vision events',
          style: TextStyle(fontSize: 10, color: Colors.black54),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    cvService.simulateAddProduct(ProductRepository.doritos);
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Doritos (\$10)', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    cvService.simulateAddProduct(ProductRepository.tuna);
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Tuna (\$65)', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    cvService.simulateAddProduct(ProductRepository.honey);
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Honey (\$145)', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    cvService.simulateRemoveProduct(ProductRepository.doritos.id);
                  },
                  icon: const Icon(Icons.remove, size: 14),
                  label: const Text('Remove Doritos', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    cvService.simulateClearCart();
                  },
                  icon: const Icon(Icons.cleaning_services, size: 14),
                  label: const Text('Clear Cart', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
