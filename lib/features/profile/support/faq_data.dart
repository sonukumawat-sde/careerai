/// Ek FAQ item.
class FaqItem {
  final String category;
  final String question;
  final String answer;

  const FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}

/// Saari FAQs (real, categorized).
const List<FaqItem> allFaqs = [
  // ---- Account ----
  FaqItem(
    category: 'Account',
    question: 'How do I create an account?',
    answer:
        'Tap "Create Account" on the login screen, enter your name, email, and password. You can also add a referral code to earn bonus points!',
  ),
  FaqItem(
    category: 'Account',
    question: 'How do I change my password?',
    answer:
        'Go to Profile → Privacy & Security → Change Password. Enter your new password and confirm it.',
  ),
  FaqItem(
    category: 'Account',
    question: 'Can I change my profile photo?',
    answer:
        'Yes! Go to Profile → Edit Profile, tap on your avatar, and choose a photo from your gallery.',
  ),
  FaqItem(
    category: 'Account',
    question: 'How do I delete my account?',
    answer:
        'Go to Profile → Privacy & Security → Delete Account. Please note this permanently deletes all your data and cannot be undone.',
  ),

  // ---- Resume ----
  FaqItem(
    category: 'Resume',
    question: 'How does the Resume Analyzer work?',
    answer:
        'Upload your resume (PDF), and our AI analyzes it to give you a score, ATS compatibility check, strengths, weaknesses, and personalized suggestions.',
  ),
  FaqItem(
    category: 'Resume',
    question: 'What is an ATS score?',
    answer:
        'ATS (Applicant Tracking System) score shows how well your resume can be read by automated hiring software that companies use to filter candidates.',
  ),
  FaqItem(
    category: 'Resume',
    question: 'Where can I see my analyzed resumes?',
    answer:
        'All your analyzed resumes are saved in the menu under "My Resumes" with their scores.',
  ),

  // ---- Jobs ----
  FaqItem(
    category: 'Jobs',
    question: 'Are the jobs real and updated?',
    answer:
        'Yes! We fetch real, live job listings from across the web. New jobs are added continuously.',
  ),
  FaqItem(
    category: 'Jobs',
    question: 'How do I apply to a job?',
    answer:
        'Open any job, tap "Apply Now". You will be taken to the company\'s official application page, and the job is tracked in your Application Tracker.',
  ),
  FaqItem(
    category: 'Jobs',
    question: 'How do I save a job for later?',
    answer:
        'Tap the bookmark icon on any job card. Saved jobs appear in the menu under "Saved Jobs".',
  ),
  FaqItem(
    category: 'Jobs',
    question: 'How do I track my applications?',
    answer:
        'Every job you apply to is saved in "Application Tracker" (in the menu), showing its status from Applied to Offer.',
  ),

  // ---- Rewards ----
  FaqItem(
    category: 'Rewards',
    question: 'How do I earn points?',
    answer:
        'You earn points for activities: analyzing a resume (+10), applying to a job (+5), saving a job (+2), and referring a friend (+50).',
  ),
  FaqItem(
    category: 'Rewards',
    question: 'How does Refer & Earn work?',
    answer:
        'Share your referral code with friends. When they sign up using your code, you both earn bonus points!',
  ),
  FaqItem(
    category: 'Rewards',
    question: 'What are achievements?',
    answer:
        'Achievements are badges you unlock by completing milestones like your first application, analyzing 5 resumes, or referring friends.',
  ),

  // ---- Premium ----
  FaqItem(
    category: 'Premium',
    question: 'What does CareerAI Pro offer?',
    answer:
        'Pro unlocks unlimited AI resume analysis, priority support, advanced interview practice, and more premium features.',
  ),
  FaqItem(
    category: 'Premium',
    question: 'How do I upgrade to Pro?',
    answer:
        'Tap "Upgrade to Pro" from your Profile or the home banner to see plans and subscribe.',
  ),
];

/// FAQ categories list.
const List<String> faqCategories = [
  'All',
  'Account',
  'Resume',
  'Jobs',
  'Rewards',
  'Premium',
];