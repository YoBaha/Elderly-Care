import 'package:flutter/material.dart';
import '/services/collect_api_service.dart';
import '/models/pharmacy.dart';

class PharmacyScreen extends StatelessWidget {
  final CollectApiService collectApiService = CollectApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pharmacy Locations"),
      ),
      body: FutureBuilder<List<Pharmacy>>(
        future: collectApiService.getPharmacies(
            'Tunisia'), // You can replace 'Ankara' with a dynamic city
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var pharmacies = snapshot.data!;
            return ListView.builder(
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                var pharmacy = pharmacies[index];
                return _buildPharmacyTile(pharmacy);
              },
            );
          } else {
            return Center(child: Text('No pharmacies found.'));
          }
        },
      ),
    );
  }

  Widget _buildPharmacyTile(Pharmacy pharmacy) {
    return ListTile(
      title: Text(pharmacy.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pharmacy.address),
          Text(pharmacy.phone),
        ],
      ),
    );
  }
}
