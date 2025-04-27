import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/doctor_viewmodel.dart';
import '../models/doctor.dart';

class SpecialtyDoctorsScreen extends StatelessWidget {
  final String specialization;

  SpecialtyDoctorsScreen({required this.specialization});

  @override
  Widget build(BuildContext context) {
    final doctorViewModel = Provider.of<DoctorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(specialization),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Doctor>>(
        future: doctorViewModel.fetchDoctorsBySpecialization(specialization),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No doctors found for this specialization.'));
          }

          final doctors = snapshot.data!;

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorCard(doctor: doctor);
            },
          );
        },
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: doctor.profilePictureUrl.isNotEmpty
              ? NetworkImage(doctor.profilePictureUrl)
              : AssetImage('assets/doctor.png') as ImageProvider,
        ),
        title: Text('${doctor.firstName} ${doctor.lastName}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctor.specialization),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${doctor.rating.toStringAsFixed(1)}'),
                SizedBox(width: 16),
                Icon(Icons.location_on, size: 16),
                Text(' 800m away'),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to doctor details screen
        },
      ),
    );
  }
}
