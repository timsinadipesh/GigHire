// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class JobDetailsScreen extends StatefulWidget {
//   final String jobId;

//   const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

//   @override
//   _JobDetailsScreenState createState() => _JobDetailsScreenState();
// }

// class _JobDetailsScreenState extends State<JobDetailsScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Map<String, dynamic>? _jobDetails;
//   bool _isLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchJobDetails();
//   }

//   Future<void> _fetchJobDetails() async {
//     try {
//       DocumentSnapshot jobDoc = await _firestore
//           .collection('jobs')
//           .doc(widget.jobId)
//           .get();

//       if (jobDoc.exists) {
//         setState(() {
//           _jobDetails = jobDoc.data() as Map<String, dynamic>;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Job not found';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to load job details: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Text(
//           'Job Details',
//           style: TextStyle(color: Color(0xFF4CAF50)),
//         ),
//         iconTheme: IconThemeData(color: Color(0xFF4CAF50)),
//       ),
//       body: _isLoading
//           ? Center(
//         child: CircularProgressIndicator(
//           color: Color(0xFF4CAF50),
//         ),
//       )
//           : _errorMessage.isNotEmpty
//           ? Center(
//         child: Text(
//           _errorMessage,
//           style: TextStyle(color: Colors.white),
//         ),
//       )
//           : SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Job Title
//               Text(
//                 _jobDetails?['jobTitle'] ?? 'No Title',
//                 style: TextStyle(
//                   color: Color(0xFF4CAF50),
//                   fontSize: 24.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16.0),

//               // Job Details Grid
//               _buildJobDetailsGrid(),

//               // Problem Description
//               SizedBox(height: 16.0),
//               Text(
//                 'Problem Description',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8.0),
//               Text(
//                 _jobDetails?['problemDescription'] ?? 'No description available',
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 16.0,
//                 ),
//               ),

//               // Images Section
//               SizedBox(height: 16.0),
//               _buildImagesSection(),

//               // Action Button
//               SizedBox(height: 24.0),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _applyForJob,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF4CAF50),
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(
//                         vertical: 16.0,
//                         horizontal: 32.0
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                   ),
//                   child: Text(
//                     'Apply for Job',
//                     style: TextStyle(fontSize: 16.0),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildJobDetailsGrid() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(0xFF2A2A2A),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           _buildDetailRow('Location', _jobDetails?['location'] ?? 'Not specified'),
//           _buildDetailRow('Hourly Pay', 'Rs. ${_jobDetails?['hourlyPay'] ?? 'N/A'}'),
//           _buildDetailRow('Deadline', _jobDetails?['deadline'] ?? 'Not set'),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white70,
//               fontSize: 16.0,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImagesSection() {
//     List<dynamic> images = _jobDetails?['images'] ?? [];

//     if (images.isEmpty) {
//       return SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Problem Images',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18.0,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 8.0),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: images.map((imageUrl) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(10.0),
//                   child: CachedNetworkImage(
//                     imageUrl: imageUrl,
//                     width: 150,
//                     height: 150,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Center(
//                       child: CircularProgressIndicator(
//                         color: Color(0xFF4CAF50),
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => Icon(Icons.error),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   void _applyForJob() {
//     // TODO: Implement job application logic
//     // This could open a bottom sheet, navigate to an application form,
//     // or send an application to the client
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Job application feature coming soon!'),
//         backgroundColor: Color(0xFF4CAF50),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobId;

  const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _jobDetails;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  Future<void> _fetchJobDetails() async {
    try {
      DocumentSnapshot jobDoc =
          await _firestore.collection('jobs').doc(widget.jobId).get();

      if (jobDoc.exists) {
        setState(() {
          _jobDetails = jobDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Job not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load job details: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text(
          "Job Details",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.green,
        elevation: 2,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Title
                        Text(
                          _jobDetails?['jobTitle'] ?? 'No Title',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.0),

                        // Job Details Grid
                        _buildJobDetailsGrid(),

                        // Problem Description
                        SizedBox(height: 16.0),
                        Text(
                          'Problem Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          _jobDetails?['problemDescription'] ??
                              'No description available',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16.0,
                          ),
                        ),

                        // Images Section
                        SizedBox(height: 16.0),
                        _buildImagesSection(),

                        // Action Button
                        SizedBox(height: 24.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: _applyForJob,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 32.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Apply for Job',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildJobDetailsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDetailRow(
              'Location', _jobDetails?['location'] ?? 'Not specified'),
          _buildDetailRow(
              'Hourly Pay', 'Rs. ${_jobDetails?['hourlyPay'] ?? 'N/A'}'),
          _buildDetailRow('Deadline', _jobDetails?['deadline'] ?? 'Not set'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.0,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    List<dynamic> images = _jobDetails?['images'] ?? [];

    if (images.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Problem Images',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: images.map((imageUrl) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _applyForJob() {
    // TODO: Implement job application logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job application feature coming soon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}
