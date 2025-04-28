import 'package:flutter/material.dart';
import '/services/collect_api_service.dart';
import '/models/pharmacy.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  _PharmacyScreenState createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final CollectApiService collectApiService = CollectApiService();
  late Future<List<Pharmacy>> _pharmaciesFuture;
  List<Pharmacy> _pharmacies = [];
  List<Pharmacy> _filteredPharmacies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pharmaciesFuture = collectApiService.getPharmacies('Tunisia');
    _loadPharmacies();
    _searchController.addListener(_filterPharmacies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacies() async {
    final pharmacies = await _pharmaciesFuture;
    setState(() {
      _pharmacies = pharmacies;
      _filteredPharmacies = pharmacies;
    });
  }

  Future<void> _refreshPharmacies() async {
    setState(() {
      _pharmaciesFuture = collectApiService.getPharmacies('Tunisia');
    });
    await _loadPharmacies();
  }

  void _filterPharmacies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPharmacies = _pharmacies.where((pharmacy) {
        final nameMatch = pharmacy.name.toLowerCase().contains(query);
        final addressMatch = pharmacy.address.toLowerCase().contains(query);
        return nameMatch || addressMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy Locations"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPharmacies,
            tooltip: 'Refresh Pharmacies',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search pharmacies...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            // Pharmacy List
            FutureBuilder<List<Pharmacy>>(
              future: _pharmaciesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (_filteredPharmacies.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_pharmacy_outlined,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No pharmacies found.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_searchController.text.isNotEmpty)
                            const Text(
                              'Try adjusting your search.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredPharmacies.length,
                    itemBuilder: (context, index) {
                      var pharmacy = _filteredPharmacies[index];
                      return _buildPharmacyCard(pharmacy);
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Pharmacy Icon
              const Icon(
                Icons.local_pharmacy,
                size: 40,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 16),
              // Pharmacy Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.store,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pharmacy.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pharmacy.address,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pharmacy.phone,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
