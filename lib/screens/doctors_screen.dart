import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/doctor_viewmodel.dart';
import '../models/doctor.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({Key? key}) : super(key: key);

  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorViewModel>(context, listen: false)
          .fetchDoctors()
          .then((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorViewModel = Provider.of<DoctorViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Find Doctors',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: "Find a doctor",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20),

              // Categories Section
              Text("Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildCategory("General", Icons.medical_services),
                  _buildCategory("Lungs Specialist", Icons.vaccines_rounded),
                  _buildCategory("Dentist", Icons.health_and_safety),
                  _buildCategory("Psychiatrist", Icons.psychology),
                  _buildCategory("Covid-19", Icons.coronavirus),
                  _buildCategory("Surgeon", Icons.vaccines),
                  _buildCategory("Cardiologist", Icons.favorite),
                  _buildCategory("Pediatrician", Icons.child_care),
                  _buildCategory("Dermatologist", Icons.local_hospital),
                  _buildCategory("Neurologist", Icons.health_and_safety),
                  _buildCategory("Orthopedist", Icons.sports_handball),
                  _buildCategory("Gynecologist", Icons.female),
                  _buildCategory("Urologist", Icons.accessibility),
                  _buildCategory("Ophthalmologist", Icons.visibility),
                  _buildCategory("Endocrinologist", Icons.local_hospital),
                  _buildCategory("Radiologist", Icons.scanner),
                ],
              ),
              SizedBox(height: 20),

              // Recommended Doctors Section
              Text("Recommended Doctors",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildDoctorList(doctorViewModel),
              SizedBox(height: 20),

              // Recent Doctors Section
              Text("Your Recent Doctors",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              _buildRecentDoctors(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: Icon(icon, color: Colors.teal, size: 30),
        ),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 14))
      ],
    );
  }

  Widget _buildDoctorList(DoctorViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorMessage.isNotEmpty) {
      return Center(child: Text('Error: ${viewModel.errorMessage}'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: viewModel.doctors.length,
      itemBuilder: (context, index) {
        final doctor = viewModel.doctors[index];
        return DoctorCard(doctor: doctor);
      },
    );
  }

  Widget _buildRecentDoctors() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRecentDoctor("Dr. Marcus"),
        _buildRecentDoctor("Dr. Maria"),
        _buildRecentDoctor("Dr. Stevi"),
        _buildRecentDoctor("Dr. Luke"),
      ],
    );
  }

  Widget _buildRecentDoctor(String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage("assets/doctor.png"),
        ),
        SizedBox(height: 5),
        Text(name, style: TextStyle(fontSize: 14))
      ],
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
          // Navigate to doctor details screenr
        },
      ),
    );
  }
}
