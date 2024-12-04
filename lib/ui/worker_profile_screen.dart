// import 'package:flutter/material.dart';
//
// class WorkerDetailScreen extends StatefulWidget {
//   const WorkerDetailScreen({Key? key}) : super(key: key);
//
//   @override
//   State<WorkerDetailScreen> createState() => _WorkerDetailScreen();
// }
//
// class _WorkerDetailScreen extends State<WorkerDetailScreen> {
//   Map<String, dynamic> userData = {
//     'name': 'John Doe',
//     'title': 'Electrician',
//     'rating': 4.5,
//     'location': '[27.34° N, 110.12° W]',
//     'skills': ['HVAC', 'Electronics', 'Household'],
//     'email': 'john.doe@gmail.com',
//     'phone': '+92386429374',
//     'about': 'If u need me, i\'m here',
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Details'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               userData['name']!,
//               style: TextStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               userData['title']!,
//               style: TextStyle(
//                 fontSize: 18.0,
//                 color: Colors.grey,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'Rating: ${userData['rating']!.toStringAsFixed(1)}',
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Location: ${userData['location']!}',
//               style: TextStyle(
//                 fontSize: 16.0,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'Skills:',
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8.0),
//             Wrap(
//               spacing: 8.0,
//               children: [
//                 for (final skill in userData['skills']!)
//                   Chip(
//                     label: Text(skill),
//                     backgroundColor: Colors.grey[200],
//                   ),
//               ],
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'Contact:',
//               style: TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Email: ${userData['email']!}',
//               style: TextStyle(
//                 fontSize: 16.0,
//               ),
//             ),
//             SizedBox(height: 8.0),
//             Text(
//               'Phone: ${userData['phone']!}',
//               style: TextStyle(
//                 fontSize: 16.0,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Text(
//               'About: "${userData['about']!}"',
//               style: TextStyle(
//                 fontSize: 16.0,
//               ),
//             ),
//             SizedBox(height: 16.0),
//             Align(
//               alignment: Alignment.centerRight,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // Handle "Hire Now" button press
//                 },
//                 child: Text('Hire Now'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class WorkerDetailScreen extends StatefulWidget {
  const WorkerDetailScreen({Key? key}) : super(key: key);

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  // Updated user data to match the SVG prototype
  Map<String, dynamic> userData = {
    'name': 'Michael Chen',
    'title': 'Full Stack Developer',
    'rating': 4.9,
    'jobs': 127,
    'success_rate': 98,
    'about': 'Full stack developer with 5+ years of experience. '
        'Specialized in React, Node.js, and Python. '
        'Available for both short-term and long-term projects.',
    'skills': ['React', 'Node.js', 'Python'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status bar simulation (typically handled by system)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),

              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF333333),
                    ),
                    SizedBox(height: 16),
                    Text(
                      userData['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData['title'],
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      value: '${userData['rating']}',
                      label: 'Rating',
                    ),
                    _buildStatCard(
                      value: '${userData['jobs']}',
                      label: 'Jobs',
                    ),
                    _buildStatCard(
                      value: '${userData['success_rate']}%',
                      label: 'Success',
                    ),
                  ],
                ),
              ),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2a2a2a),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        userData['about'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Skills Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: userData['skills'].map<Widget>((skill) =>
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFF2a2a2a),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          )
                      ).toList(),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Hire Now action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Hire Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Message action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2a2a2a),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Message',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
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

  // Helper method to create stat cards
  Widget _buildStatCard({required String value, required String label}) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}