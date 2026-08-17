import 'admin_models.dart';

class AdminMockData {
  static final List<AdminAccount> adminAccounts = [
    AdminAccount(id: 'admin-1', email: 'admin@acadyk.edu', name: 'Sudhanshu Patel', role: 'SUPER_ADMIN'),
    AdminAccount(id: 'admin-2', email: 'editor@acadyk.edu', name: 'Ananya Roy', role: 'EDITOR'),
    AdminAccount(id: 'admin-3', email: 'viewer@acadyk.edu', name: 'Aarav Sharma', role: 'VIEWER'),
  ];

  static final List<String> adminPasswords = [
    'SuperAdmin2026!',
    'Editor2026!',
    'Viewer2026!',
  ];

  static int _userIdCounter = 20;
  static int _contentIdCounter = 20;
  static int _activityIdCounter = 20;
  static int _eventIdCounter = 10;
  static int _orgIdCounter = 10;
  static int _noticeIdCounter = 10;
  static int _resultIdCounter = 10;

  static String nextUserId() => 'u-${++_userIdCounter}';
  static String nextContentId() => 'p-${++_contentIdCounter}';
  static String nextActivityId() => 'a-${++_activityIdCounter}';
  static String nextEventId() => 'ev-${++_eventIdCounter}';
  static String nextOrgId() => 'org-${++_orgIdCounter}';
  static String nextNoticeId() => 'n-${++_noticeIdCounter}';
  static String nextResultId() => 'r-${++_resultIdCounter}';

  // Available filter options for MITS-DU
  static const List<String> courses = ['B.Tech', 'M.Tech', 'MBA', 'MCA', 'B.Pharm'];
  static const List<String> branches = ['AIML', 'CSE', 'ECE', 'EE', 'ME', 'Civil', 'IT', 'Chemical'];
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Electronics & Communication',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Information Technology',
    'Chemical Engineering',
    'Applied Sciences',
  ];

  // ==================== USERS ====================
  static final List<ManagedUser> users = [
    ManagedUser(id: 'u-1', fullName: 'Sudhanshu Patel', email: 'sudhanshu@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science & Engineering', enrollmentNumber: 'BTAM25O1062', course: 'B.Tech', branch: 'AIML', year: 1, semester: 2, batch: '2025-2029', phone: '9876543210', clubIds: ['org-1', 'org-3'], teamIds: ['org-5'], eventIds: ['ev-1', 'ev-2'], joinedAt: DateTime(2024, 3, 15), lastActive: DateTime.now(), postsCount: 12),
    ManagedUser(id: 'u-2', fullName: 'Aarav Sharma', email: 'aarav@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science & Engineering', enrollmentNumber: 'BTCS25O1015', course: 'B.Tech', branch: 'CSE', year: 1, semester: 2, batch: '2025-2029', phone: '9876543211', clubIds: ['org-1'], teamIds: [], eventIds: ['ev-1', 'ev-3'], joinedAt: DateTime(2024, 1, 10), lastActive: DateTime.now().subtract(const Duration(hours: 2)), postsCount: 28),
    ManagedUser(id: 'u-3', fullName: 'Ananya Roy', email: 'ananya@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Information Technology', enrollmentNumber: 'BTIT25O1008', course: 'B.Tech', branch: 'IT', year: 1, semester: 2, batch: '2025-2029', phone: '9876543212', clubIds: ['org-2'], teamIds: ['org-6'], eventIds: ['ev-2'], joinedAt: DateTime(2024, 2, 20), lastActive: DateTime.now().subtract(const Duration(days: 1)), postsCount: 14),
    ManagedUser(id: 'u-4', fullName: 'Dr. Rajesh Verma', email: 'rajesh.verma@acadyk.edu', role: 'FACULTY', status: 'active', department: 'Computer Science & Engineering', employeeId: 'EMP1001', designation: 'Professor', phone: '9876543220', clubIds: [], teamIds: [], eventIds: ['ev-1'], joinedAt: DateTime(2023, 8, 1), lastActive: DateTime.now().subtract(const Duration(hours: 5)), postsCount: 42),
    ManagedUser(id: 'u-5', fullName: 'Priya Nair', email: 'priya@acadyk.edu', role: 'STUDENT', status: 'suspended', department: 'Electronics & Communication', enrollmentNumber: 'BTEC24O1022', course: 'B.Tech', branch: 'ECE', year: 2, semester: 4, batch: '2024-2028', phone: '9876543213', suspensionReason: 'Academic misconduct', suspendedAt: DateTime.now().subtract(const Duration(days: 14)), suspendedBy: 'Sudhanshu Patel', clubIds: [], teamIds: [], eventIds: [], joinedAt: DateTime(2024, 6, 1), lastActive: DateTime.now().subtract(const Duration(days: 14)), postsCount: 3),
    ManagedUser(id: 'u-6', fullName: 'Siddharth Mehta', email: 'siddharth@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Mechanical Engineering', enrollmentNumber: 'BTME24O1045', course: 'B.Tech', branch: 'ME', year: 2, semester: 3, batch: '2024-2028', phone: '9876543214', clubIds: ['org-4'], teamIds: [], eventIds: ['ev-3'], joinedAt: DateTime(2024, 4, 10), lastActive: DateTime.now().subtract(const Duration(days: 3)), postsCount: 8),
    ManagedUser(id: 'u-7', fullName: 'Kavya Iyer', email: 'kavya@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science & Engineering', enrollmentNumber: 'BTCS24O1033', course: 'B.Tech', branch: 'CSE', year: 2, semester: 4, batch: '2024-2028', phone: '9876543215', clubIds: ['org-1', 'org-2'], teamIds: ['org-5'], eventIds: ['ev-1', 'ev-2', 'ev-3'], joinedAt: DateTime(2024, 7, 5), lastActive: DateTime.now().subtract(const Duration(hours: 1)), postsCount: 19),
    ManagedUser(id: 'u-8', fullName: 'Rohit Desai', email: 'rohit@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Civil Engineering', enrollmentNumber: 'BTCE23O1012', course: 'B.Tech', branch: 'Civil', year: 3, semester: 5, batch: '2023-2027', phone: '9876543216', clubIds: ['org-4'], teamIds: [], eventIds: [], joinedAt: DateTime(2024, 5, 12), lastActive: DateTime.now().subtract(const Duration(days: 7)), postsCount: 5),
    ManagedUser(id: 'u-9', fullName: 'Dr. Meera Joshi', email: 'meera.joshi@acadyk.edu', role: 'FACULTY', status: 'active', department: 'Information Technology', employeeId: 'EMP1025', designation: 'Assistant Professor', phone: '9876543221', clubIds: [], teamIds: [], eventIds: ['ev-2'], joinedAt: DateTime(2023, 6, 15), lastActive: DateTime.now().subtract(const Duration(hours: 8)), postsCount: 31),
    ManagedUser(id: 'u-10', fullName: 'Vikram Singh', email: 'vikram@acadyk.edu', role: 'STUDENT', status: 'banned', department: 'Electronics & Communication', enrollmentNumber: 'BTEC23O1041', course: 'B.Tech', branch: 'ECE', year: 3, semester: 6, batch: '2023-2027', phone: '9876543217', suspensionReason: 'Repeated policy violations', suspendedAt: DateTime.now().subtract(const Duration(days: 30)), suspendedBy: 'Sudhanshu Patel', clubIds: [], teamIds: [], eventIds: [], joinedAt: DateTime(2024, 1, 22), lastActive: DateTime.now().subtract(const Duration(days: 30)), postsCount: 1),
    ManagedUser(id: 'u-11', fullName: 'Neha Gupta', email: 'neha@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Computer Science & Engineering', enrollmentNumber: 'BTAM25O1078', course: 'B.Tech', branch: 'AIML', year: 1, semester: 2, batch: '2025-2029', phone: '9876543218', clubIds: ['org-1', 'org-3'], teamIds: ['org-6'], eventIds: ['ev-1'], joinedAt: DateTime(2024, 8, 1), lastActive: DateTime.now(), postsCount: 2),
    ManagedUser(id: 'u-12', fullName: 'Arjun Kapoor', email: 'arjun@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Mechanical Engineering', enrollmentNumber: 'BTME23O1028', course: 'B.Tech', branch: 'ME', year: 3, semester: 6, batch: '2023-2027', phone: '9876543219', clubIds: ['org-4'], teamIds: ['org-7'], eventIds: ['ev-3'], joinedAt: DateTime(2024, 3, 28), lastActive: DateTime.now().subtract(const Duration(days: 2)), postsCount: 11),
    ManagedUser(id: 'u-13', fullName: 'Dr. Amit Saxena', email: 'amit.saxena@acadyk.edu', role: 'FACULTY', status: 'active', department: 'Electrical Engineering', employeeId: 'EMP1042', designation: 'Associate Professor', phone: '9876543222', clubIds: [], teamIds: [], eventIds: [], joinedAt: DateTime(2022, 1, 10), lastActive: DateTime.now().subtract(const Duration(hours: 3)), postsCount: 18),
    ManagedUser(id: 'u-14', fullName: 'Riya Patel', email: 'riya@acadyk.edu', role: 'STUDENT', status: 'active', department: 'Electrical Engineering', enrollmentNumber: 'BTEE24O1019', course: 'B.Tech', branch: 'EE', year: 2, semester: 3, batch: '2024-2028', phone: '9876543223', clubIds: ['org-2', 'org-3'], teamIds: [], eventIds: ['ev-2'], joinedAt: DateTime(2024, 7, 15), lastActive: DateTime.now().subtract(const Duration(hours: 6)), postsCount: 7),
  ];

  // ==================== CONTENT ====================
  static final List<ManagedContent> content = [
    ManagedContent(id: 'p-1', authorName: 'Aarav Sharma', authorEmail: 'aarav@acadyk.edu', content: 'Our research paper on Optimizing Transformer Models for Edge Devices has been accepted at IEEE ICML 2026. Grateful to Dr. Verma for the mentorship.', postType: 'research', status: 'published', likeCount: 142, commentCount: 28, createdAt: DateTime.now().subtract(const Duration(hours: 2)), organizationId: 'org-1'),
    ManagedContent(id: 'p-2', authorName: 'Ananya Roy', authorEmail: 'ananya@acadyk.edu', content: 'Annual Campus Startup Demo Day is officially live. Over 20 student-led startups presenting their work today in the main auditorium.', postType: 'announcement', status: 'published', likeCount: 89, commentCount: 14, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ManagedContent(id: 'p-3', authorName: 'Dr. Rajesh Verma', authorEmail: 'rajesh.verma@acadyk.edu', content: 'Applications open for the Autumn 2026 Undergraduate Research Fellowship. Monthly stipend of Rs 12,000. Apply by September 15.', postType: 'opportunity', status: 'published', likeCount: 215, commentCount: 42, reportCount: 0, createdAt: DateTime.now().subtract(const Duration(days: 1))),
    ManagedContent(id: 'p-4', authorName: 'Unknown User', authorEmail: 'spam@external.com', content: 'Buy cheap followers and likes! Visit our site now for amazing deals on social media growth and assignments...', postType: 'text', status: 'flagged', likeCount: 1, commentCount: 0, reportCount: 12, createdAt: DateTime.now().subtract(const Duration(hours: 8))),
    ManagedContent(id: 'p-5', authorName: 'Kavya Iyer', authorEmail: 'kavya@acadyk.edu', content: 'Just completed the AWS Cloud Practitioner certification. Here are my study notes and resources for anyone preparing.', postType: 'text', status: 'published', likeCount: 67, commentCount: 9, createdAt: DateTime.now().subtract(const Duration(hours: 12)), organizationId: 'org-1'),
    ManagedContent(id: 'p-6', authorName: 'Siddharth Mehta', authorEmail: 'siddharth@acadyk.edu', content: 'Looking for teammates for Smart India Hackathon 2026. Need 2 developers and 1 designer. DM if interested.', postType: 'text', status: 'published', likeCount: 34, commentCount: 18, createdAt: DateTime.now().subtract(const Duration(days: 2))),
    ManagedContent(id: 'p-7', authorName: 'Rohit Desai', authorEmail: 'rohit@acadyk.edu', content: 'Campus WiFi has been completely unstable in Block C for 3 days. Hope administration fixes it soon.', postType: 'text', status: 'flagged', likeCount: 24, commentCount: 5, reportCount: 2, createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  // ==================== EVENTS ====================
  static final List<ManagedEvent> events = [
    ManagedEvent(id: 'ev-1', title: 'CodeFest 2026', description: 'Annual coding competition featuring 48-hour hackathon, competitive programming, and project showcase. Open to all branches.', startDate: DateTime.now().add(const Duration(days: 15)), endDate: DateTime.now().add(const Duration(days: 17)), venue: 'MITS-DU Main Auditorium', organizer: 'Coding Club', organizationId: 'org-1', contactInfo: 'codefest@acadyk.edu', registrationDeadline: DateTime.now().add(const Duration(days: 10)), status: 'published', registrationsCount: 156, createdAt: DateTime.now().subtract(const Duration(days: 10)), createdBy: 'Sudhanshu Patel'),
    ManagedEvent(id: 'ev-2', title: 'TechTalk: AI in Healthcare', description: 'Guest lecture by Dr. Priya Sharma from AIIMS on applications of artificial intelligence in modern healthcare diagnostics.', startDate: DateTime.now().add(const Duration(days: 5)), endDate: DateTime.now().add(const Duration(days: 5)), venue: 'Seminar Hall B', organizer: 'AI/ML Society', organizationId: 'org-3', contactInfo: 'aiml@acadyk.edu', registrationDeadline: DateTime.now().add(const Duration(days: 3)), status: 'published', registrationsCount: 82, createdAt: DateTime.now().subtract(const Duration(days: 5)), createdBy: 'Sudhanshu Patel'),
    ManagedEvent(id: 'ev-3', title: 'Smart India Hackathon Preparatory', description: 'Preparatory workshop and team formation for Smart India Hackathon 2026. Mentors from industry will guide participating teams.', startDate: DateTime.now().add(const Duration(days: 25)), endDate: DateTime.now().add(const Duration(days: 25)), venue: 'Workshop Hall 1', organizer: 'MITS-DU Innovation Cell', contactInfo: 'innovation@acadyk.edu', registrationDeadline: DateTime.now().add(const Duration(days: 20)), status: 'scheduled', registrationsCount: 44, createdAt: DateTime.now().subtract(const Duration(days: 3)), createdBy: 'Sudhanshu Patel'),
    ManagedEvent(id: 'ev-4', title: 'Annual Sports Meet 2026', description: 'Inter-departmental sports competition covering athletics, cricket, football, basketball, and table tennis.', startDate: DateTime.now().subtract(const Duration(days: 2)), endDate: DateTime.now().subtract(const Duration(days: 1)), venue: 'MITS-DU Sports Ground', organizer: 'Sports Committee', contactInfo: 'sports@acadyk.edu', status: 'completed', registrationsCount: 320, createdAt: DateTime.now().subtract(const Duration(days: 30)), createdBy: 'Ananya Roy'),
    ManagedEvent(id: 'ev-5', title: 'Workshop: IoT with Raspberry Pi', description: 'Hands-on workshop on building IoT prototypes using Raspberry Pi and various sensors.', startDate: DateTime.now().add(const Duration(days: 8)), endDate: DateTime.now().add(const Duration(days: 8)), venue: 'Lab 204', organizer: 'Electronics Club', organizationId: 'org-2', contactInfo: 'electronics@acadyk.edu', status: 'draft', registrationsCount: 0, createdAt: DateTime.now().subtract(const Duration(days: 1)), createdBy: 'Sudhanshu Patel'),
  ];

  // ==================== ORGANIZATIONS ====================
  static final List<Organization> organizations = [
    Organization(id: 'org-1', name: 'Coding Club', type: 'club', description: 'A community of passionate coders. Weekly contests, workshops, and mentorship programs.', status: 'active', memberIds: ['u-1', 'u-2', 'u-7', 'u-11'], eventIds: ['ev-1'], department: 'Computer Science & Engineering', facultyAdvisorId: 'u-4', createdAt: DateTime(2023, 6, 1)),
    Organization(id: 'org-2', name: 'Electronics Club', type: 'club', description: 'Explore the world of electronics, robotics, and embedded systems through hands-on projects.', status: 'active', memberIds: ['u-3', 'u-7', 'u-14'], eventIds: ['ev-5'], department: 'Electronics & Communication', facultyAdvisorId: 'u-9', createdAt: DateTime(2023, 6, 1)),
    Organization(id: 'org-3', name: 'AI/ML Society', type: 'club', description: 'Research group focused on artificial intelligence, machine learning, and data science.', status: 'active', memberIds: ['u-1', 'u-11', 'u-14'], eventIds: ['ev-2'], department: 'Computer Science & Engineering', facultyAdvisorId: 'u-4', createdAt: DateTime(2024, 1, 15)),
    Organization(id: 'org-4', name: 'Mechanical Engineers Forum', type: 'club', description: 'Forum for mechanical engineering students to discuss innovations, projects, and career opportunities.', status: 'active', memberIds: ['u-6', 'u-8', 'u-12'], eventIds: [], department: 'Mechanical Engineering', createdAt: DateTime(2023, 8, 10)),
    Organization(id: 'org-5', name: 'Team CodeCraft', type: 'team', description: 'Competitive programming team representing MITS-DU at national and international contests.', status: 'active', memberIds: ['u-1', 'u-7'], eventIds: ['ev-1'], department: 'Computer Science & Engineering', createdAt: DateTime(2024, 3, 1)),
    Organization(id: 'org-6', name: 'Team InnovateTech', type: 'team', description: 'Innovation team focused on building solutions for Smart India Hackathon.', status: 'active', memberIds: ['u-3', 'u-11'], eventIds: ['ev-3'], createdAt: DateTime(2024, 5, 1)),
    Organization(id: 'org-7', name: 'Team MechPro', type: 'team', description: 'Design and fabrication team for SAE and other engineering competitions.', status: 'active', memberIds: ['u-12'], eventIds: [], department: 'Mechanical Engineering', createdAt: DateTime(2024, 2, 1)),
  ];

  // ==================== NOTICES ====================
  static final List<Notice> notices = [
    Notice(id: 'n-1', title: 'Mid-Semester Examination Schedule', content: 'Mid-semester examinations for all branches will commence from September 15, 2026. Detailed date-sheet has been uploaded to the examination portal. Students are advised to check their respective time tables.', priority: 'important', status: 'published', authorName: 'Sudhanshu Patel', createdAt: DateTime.now().subtract(const Duration(days: 2))),
    Notice(id: 'n-2', title: 'Library Timings Extended', content: 'The central library will remain open until 10:00 PM from Monday to Saturday effective immediately. Sunday timings remain unchanged (9:00 AM - 5:00 PM).', priority: 'normal', status: 'published', authorName: 'Ananya Roy', createdAt: DateTime.now().subtract(const Duration(days: 5))),
    Notice(id: 'n-3', title: 'Campus Maintenance Notice', content: 'Block C will undergo scheduled maintenance on August 25-26. Classes for affected departments will be relocated to Block A. Please check the notice board for room allocations.', priority: 'urgent', status: 'draft', authorName: 'Sudhanshu Patel', scheduledAt: DateTime.now().add(const Duration(days: 5)), createdAt: DateTime.now().subtract(const Duration(days: 1))),
    Notice(id: 'n-4', title: 'Placement Drive - TCS & Infosys', content: 'TCS and Infosys will conduct on-campus placement drives on September 5 and September 8 respectively. Eligible students (CGPA >= 6.5) must register through the placement portal by August 28.', priority: 'important', status: 'published', authorName: 'Sudhanshu Patel', organizationId: 'org-1', createdAt: DateTime.now().subtract(const Duration(days: 3))),
  ];

  // ==================== RESULTS ====================
  static final List<StudentResult> results = [
    StudentResult(
      enrollmentNumber: 'BTAM25O1062',
      cgpa: 8.6,
      semesters: [
        SemesterResult(id: 'r-1', semester: 1, sgpa: 8.6, totalCredits: 22, subjects: [
          SubjectResult(code: 'MA101', name: 'Engineering Mathematics I', credits: 4, grade: 'A', gradePoint: 9.0),
          SubjectResult(code: 'PH101', name: 'Engineering Physics', credits: 4, grade: 'A', gradePoint: 9.0),
          SubjectResult(code: 'CS101', name: 'Programming Fundamentals', credits: 4, grade: 'A+', gradePoint: 10.0),
          SubjectResult(code: 'EE101', name: 'Basic Electrical Engineering', credits: 3, grade: 'B+', gradePoint: 8.0),
          SubjectResult(code: 'ME101', name: 'Engineering Graphics', credits: 3, grade: 'B', gradePoint: 7.0),
          SubjectResult(code: 'HS101', name: 'English Communication', credits: 2, grade: 'A', gradePoint: 9.0),
          SubjectResult(code: 'WS101', name: 'Workshop Practice', credits: 2, grade: 'B+', gradePoint: 8.0),
        ]),
      ],
    ),
    StudentResult(
      enrollmentNumber: 'BTCS25O1015',
      cgpa: 9.1,
      semesters: [
        SemesterResult(id: 'r-2', semester: 1, sgpa: 9.1, totalCredits: 22, subjects: [
          SubjectResult(code: 'MA101', name: 'Engineering Mathematics I', credits: 4, grade: 'A+', gradePoint: 10.0),
          SubjectResult(code: 'PH101', name: 'Engineering Physics', credits: 4, grade: 'A', gradePoint: 9.0),
          SubjectResult(code: 'CS101', name: 'Programming Fundamentals', credits: 4, grade: 'A+', gradePoint: 10.0),
          SubjectResult(code: 'EE101', name: 'Basic Electrical Engineering', credits: 3, grade: 'A', gradePoint: 9.0),
          SubjectResult(code: 'ME101', name: 'Engineering Graphics', credits: 3, grade: 'B+', gradePoint: 8.0),
          SubjectResult(code: 'HS101', name: 'English Communication', credits: 2, grade: 'A', gradePoint: 9.0),
          SubjectResult(code: 'WS101', name: 'Workshop Practice', credits: 2, grade: 'A', gradePoint: 9.0),
        ]),
      ],
    ),
  ];

  // ==================== ACTIVITY LOG ====================
  static final List<ActivityLogEntry> activityLog = [
    ActivityLogEntry(id: 'a-1', action: 'User suspended', performedBy: 'Sudhanshu Patel', target: 'priya@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(hours: 1)), category: 'user', reason: 'Academic misconduct', targetId: 'u-5'),
    ActivityLogEntry(id: 'a-2', action: 'Content flagged', performedBy: 'System', target: 'Post p-4', timestamp: DateTime.now().subtract(const Duration(hours: 3)), category: 'content', targetId: 'p-4'),
    ActivityLogEntry(id: 'a-3', action: 'Settings updated', performedBy: 'Sudhanshu Patel', target: 'Application Settings', timestamp: DateTime.now().subtract(const Duration(hours: 6)), category: 'settings'),
    ActivityLogEntry(id: 'a-4', action: 'User role changed', performedBy: 'Sudhanshu Patel', target: 'ananya@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 1)), category: 'user', targetId: 'u-3'),
    ActivityLogEntry(id: 'a-5', action: 'New admin added', performedBy: 'Sudhanshu Patel', target: 'viewer@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 2)), category: 'user'),
    ActivityLogEntry(id: 'a-6', action: 'Content approved', performedBy: 'Ananya Roy', target: 'Post p-1', timestamp: DateTime.now().subtract(const Duration(days: 3)), category: 'content', targetId: 'p-1'),
    ActivityLogEntry(id: 'a-7', action: 'User registered', performedBy: 'System', target: 'neha@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(hours: 4)), category: 'user', targetId: 'u-11'),
    ActivityLogEntry(id: 'a-8', action: 'Content approved', performedBy: 'Ananya Roy', target: 'Post p-5', timestamp: DateTime.now().subtract(const Duration(hours: 7)), category: 'content', targetId: 'p-5'),
    ActivityLogEntry(id: 'a-9', action: 'Maintenance mode toggled', performedBy: 'Sudhanshu Patel', target: 'OFF', timestamp: DateTime.now().subtract(const Duration(days: 4)), category: 'settings'),
    ActivityLogEntry(id: 'a-10', action: 'User banned', performedBy: 'Sudhanshu Patel', target: 'vikram@acadyk.edu', timestamp: DateTime.now().subtract(const Duration(days: 5)), category: 'user', reason: 'Repeated policy violations', targetId: 'u-10'),
    ActivityLogEntry(id: 'a-11', action: 'Event created', performedBy: 'Sudhanshu Patel', target: 'CodeFest 2026', timestamp: DateTime.now().subtract(const Duration(days: 10)), category: 'event', targetId: 'ev-1'),
    ActivityLogEntry(id: 'a-12', action: 'Event published', performedBy: 'Sudhanshu Patel', target: 'CodeFest 2026', timestamp: DateTime.now().subtract(const Duration(days: 9)), category: 'event', targetId: 'ev-1'),
    ActivityLogEntry(id: 'a-13', action: 'Notice published', performedBy: 'Sudhanshu Patel', target: 'Mid-Semester Examination Schedule', timestamp: DateTime.now().subtract(const Duration(days: 2)), category: 'notice', targetId: 'n-1'),
    ActivityLogEntry(id: 'a-14', action: 'Organization created', performedBy: 'Sudhanshu Patel', target: 'AI/ML Society', timestamp: DateTime(2024, 1, 15), category: 'organization', targetId: 'org-3'),
  ];

  static AppSettingsModel get defaultSettings => AppSettingsModel();
}