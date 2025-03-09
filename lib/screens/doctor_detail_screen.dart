import 'package:flutter/material.dart';
import '../models/doctor.dart';

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Detail'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '9:41',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: doctor.profilePictureUrl.isNotEmpty
                      ? NetworkImage(doctor.profilePictureUrl)
                      : null,
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${doctor.firstName} ${doctor.lastName}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor.specialization,
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(
                          doctor.rating.toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${doctor.distance.toStringAsFixed(1)}km away',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam... Read more',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDayButton('Mon', '21'),
                  _buildDayButton('Tue', '22'),
                  _buildDayButton('Wed', '23'),
                  _buildDayButton('Thu', '24'),
                  _buildDayButton('Fri', '25'),
                  _buildDayButton('Sat', '26'),
                ],
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _buildTimeSlotButton('10:00 AM'),
                _buildTimeSlotButton('02:00 PM'),
                _buildTimeSlotButton('03:00 PM'),
                _buildTimeSlotButton('04:00 PM'),
                _buildTimeSlotButton('07:00 PM'),
              ],
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle booking appointment
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: Text(
                    'Book Appointment',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(String day, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Text(day, style: TextStyle(fontSize: 16)),
          SizedBox(height: 4),
          Text(date, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTimeSlotButton(String time) {
    return ElevatedButton(
      onPressed: () {
        // Handle time slot selection
      },
      child: Text(time),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
