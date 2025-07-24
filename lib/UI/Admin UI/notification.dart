import 'package:decor_lens/Services/notification_services.dart';
import 'package:decor_lens/Services/send_notification_service.dart';
import 'package:decor_lens/Utils/colors.dart';
import 'package:decor_lens/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  late Stream<QuerySnapshot> notificationStream;

  @override
  void initState() {
    super.initState();
    notificationStream = FirebaseFirestore.instance
        .collection('Notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();

    NotificationService notificationService = NotificationService();
    notificationService.getDeviceToken();
  }

  void showNotificationSheet() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Theme(
          data: ThemeData.light(),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        '📢 Send New Notification',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: deepPurple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Title',
                      style: GoogleFonts.poppins(
                          color: black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter notification title',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Body',
                      style: GoogleFonts.poppins(
                          color: black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bodyController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter notification message',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send, size: 20),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final body = bodyController.text.trim();

                          if (title.isEmpty || body.isEmpty) {
                            Get.snackbar("⚠️ Missing Fields",
                                "Please enter both title and body.");
                            return;
                          }

                          await SendNotificationService
                              .sendNotificationUsingApi(
                                  title: title,
                                  body: body,
                                  topic: "all_users",
                                  data: {"screen": 'notification'});

                          await saveNotificationToFirestore(title, body);

                          Navigator.pop(context);
                        },
                        label: Text(
                          'Send Notification',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildNotificationTile(DocumentSnapshot doc) {
    final isLatest = doc['latest'] == "1";
    final title = doc['title'] ?? '';
    final body = doc['body'] ?? '';
    final timestamp = (doc['timestamp'] as Timestamp?)?.toDate();

    return Card(
      elevation: isLatest ? 6 : 2,
      color: isLatest ? Colors.green.shade50 : Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(
            isLatest ? Icons.fiber_new : Icons.notifications_none_outlined,
            color: isLatest ? Colors.green : Colors.grey),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          body,
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(doc.id),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notification"),
        content:
            const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: red),
            child: Text(
              "Delete",
              style: TextStyle(color: white),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseFirestore.instance
                  .collection('Notifications')
                  .doc(docId)
                  .delete();

              Get.snackbar("✅ Deleted", "Notification has been deleted.");
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: adminAppbar,
          elevation: 0,
          title: Text('Admin Notifications',
              style: GoogleFonts.poppins(
                fontSize: screenHeight * 0.03,
                color: white,
                fontWeight: FontWeight.w600,
              )),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: notificationStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No notifications found.'));
            }

            return ListView(
              children: snapshot.data!.docs.map(buildNotificationTile).toList(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: showNotificationSheet,
          label: Text(
            'New Notification',
            style: GoogleFonts.manrope(color: white),
          ),
          icon: Icon(
            Icons.add_alert,
            color: white,
          ),
          backgroundColor: appColor,
        ),
      ),
    );
  }
}
