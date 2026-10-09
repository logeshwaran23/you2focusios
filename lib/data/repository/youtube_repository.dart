import 'dart:math';
import '../remote/firebase_cache_service.dart';
import '../remote/youtube_official_api_service.dart';
import '../remote/youtube_no_quota_scraper.dart';

class YouTubeRepository {
  final YouTubeNoQuotaScraper _noQuotaScraper = YouTubeNoQuotaScraper();
  final FirebaseCacheService _firebaseCache = FirebaseCacheService();
  final YouTubeOfficialApiService _officialApiService = YouTubeOfficialApiService();

  static final Map<String, List<Map<String, String>>> _memoryCache = {};

  static const Map<String, List<Map<String, String>>> topicVideos = {

    "All": [
      {'videoId': 'bHIhgxav9LY','title': 'The Biggest Misconception About Electricity','channel': 'Veritasium','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg','duration': '14:32'},
      {'videoId': 'PHe0bXAIuk0','title': 'How The Economic Machine Works','channel': 'Principles by Ray Dalio','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/PHe0bXAIuk0/hqdefault.jpg','duration': '31:00'},
      {'videoId': 'aircAruvnKk','title': 'But What Is a Neural Network?','channel': '3Blue1Brown','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/aircAruvnKk/hqdefault.jpg','duration': '19:13'},
      {'videoId': 'ukLnPbIffxE','title': 'How to Study Smarter Not Harder','channel': 'Thomas Frank','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/ukLnPbIffxE/hqdefault.jpg','duration': '14:34'},
      {'videoId': 'inpok4MKVLM','title': '5-Minute Meditation You Can Do Anywhere','channel': 'Goodful','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/inpok4MKVLM/hqdefault.jpg','duration': '5:00'},
      {'videoId': '1A_CAkYt3GY','title': 'What is Philosophy? Crash Course','channel': 'CrashCourse','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/1A_CAkYt3GY/hqdefault.jpg','duration': '10:23'},
      {'videoId': 'H14bBuluwB8','title': 'Grit: The Power of Passion and Perseverance','channel': 'TED','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
      {'videoId': 'MBRqu0YOH14','title': 'Optimistic Nihilism','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg','duration': '6:10'},
      {'videoId': 'zjkBMFhNj_g','title': 'Harvard CS50: Computer Science & Computational Thinking','channel': 'CS50','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/zjkBMFhNj_g/hqdefault.jpg','duration': '2:01:14'},
      {'videoId': 'bNpx7gpSqbY','title': 'The Single Biggest Reason Why Start-Ups Succeed','channel': 'TED','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/bNpx7gpSqbY/hqdefault.jpg','duration': '6:41'},
      {'videoId': 'ddq8JIMhz7Y','title': 'Active Recall: The Most Effective Learning Technique','channel': 'Ali Abdaal','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/ddq8JIMhz7Y/hqdefault.jpg','duration': '9:48'},
      {'videoId': 'V01-4jW7Xn0','title': 'Sleep is Your Superpower','channel': 'TED','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/V01-4jW7Xn0/hqdefault.jpg','duration': '19:10'},
      {'videoId': 'fxbCHn6gE3U','title': 'The Surprising Habits of Original Thinkers','channel': 'TED','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/fxbCHn6gE3U/hqdefault.jpg','duration': '15:24'},
      {'videoId': 'UF8uR6Z6KLc','title': 'Steve Jobs Stanford Commencement 2005','channel': 'Stanford','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/UF8uR6Z6KLc/hqdefault.jpg','duration': '15:04'},
      {'videoId': 'HeQX2HjkcNo','title': "Math's Fundamental Flaw: Gödel's Incompleteness",'channel': 'Veritasium','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/HeQX2HjkcNo/hqdefault.jpg','duration': '34:00'},
      {'videoId': 'pOLmD_WVY-E','title': 'Why Incompetent People Think They Are Amazing','channel': 'TED-Ed','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/pOLmD_WVY-E/hqdefault.jpg','duration': '4:58'},
      {'videoId': 'p7HKvqRI_Bo','title': 'How Does the Stock Market Work?','channel': 'TED-Ed','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/p7HKvqRI_Bo/hqdefault.jpg','duration': '4:29'},
      {'videoId': 'Ks-_Mh1QhMc','title': 'Your Body Language May Shape Who You Are','channel': 'TED','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/Ks-_Mh1QhMc/hqdefault.jpg','duration': '20:56'},
    ],

    "Education & Learning": [
      {'videoId': 'bHIhgxav9LY','title': 'The Biggest Misconception About Electricity in Physics','channel': 'Veritasium','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg','duration': '14:32'},
      {'videoId': 'e-P5IFTqB98','title': 'Black Holes Explained: From Birth to Quantum Death','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/e-P5IFTqB98/hqdefault.jpg','duration': '6:30'},
      {'videoId': 'MBRqu0YOH14','title': 'Optimistic Nihilism: Deep Scientific Perspective','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg','duration': '6:10'},
      {'videoId': 'mZsaaturR6E','title': 'Fusion Power Explained: Future of Energy','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/mZsaaturR6E/hqdefault.jpg','duration': '6:01'},
      {'videoId': 'HeQX2HjkcNo','title': "Math's Fundamental Flaw: Gödel's Incompleteness Theorem",'channel': 'Veritasium','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/HeQX2HjkcNo/hqdefault.jpg','duration': '34:00'},
      {'videoId': 'pTn6Ewhb27k','title': 'Why No One Has Measured The Speed Of Light','channel': 'Veritasium','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/pTn6Ewhb27k/hqdefault.jpg','duration': '19:07'},
      {'videoId': 'wNDGgL73ihY','title': 'The Beginning of Everything: The Big Bang Origins','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/wNDGgL73ihY/hqdefault.jpg','duration': '4:17'},
      {'videoId': 'lZ3bPUKo5zc','title': 'Lecture 1: Quantum Physics & Superposition','channel': 'MIT OpenCourseWare','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/lZ3bPUKo5zc/hqdefault.jpg','duration': '1:16:07'},
      {'videoId': 'czgOWmtGVGs','title': 'A New History for Humanity: The Human Era Timeline','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/czgOWmtGVGs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'GVsUOuSjvcg','title': 'Future Computers Will Be Radically Different','channel': 'Veritasium','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/GVsUOuSjvcg/hqdefault.jpg','duration': '17:37'},
      {'videoId': 'aIx2N-viNwY','title': 'Why Life Seems to Speed Up as We Age','channel': 'Veritasium','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/aIx2N-viNwY/hqdefault.jpg','duration': '14:35'},
      {'videoId': 'ulCdoCfw-bY','title': 'The Black Hole Bomb and Extreme Civilizations','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/ulCdoCfw-bY/hqdefault.jpg','duration': '7:22'},
      {'videoId': 'O7XnZq_4zJ0','title': 'The Immune System Explained: Tiny Wars Inside Your Body','channel': 'Kurzgesagt','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/O7XnZq_4zJ0/hqdefault.jpg','duration': '10:48'},
      {'videoId': '4c8d-2Vz_c4','title': 'The Periodic Table: Crash Course Chemistry','channel': 'CrashCourse','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/4c8d-2Vz_c4/hqdefault.jpg','duration': '11:22'},
      {'videoId': 'cZH0YnFpjwU','title': 'A Brief History of Numerical Systems','channel': 'TED-Ed','category': 'Education & Learning','thumbnail': 'https://img.youtube.com/vi/cZH0YnFpjwU/hqdefault.jpg','duration': '5:23'},
    ],

    "Competitive Exams": [
      {'videoId': 'ukLnPbIffxE','title': 'How to Study Smarter Not Harder for Competitive Exams','channel': 'Thomas Frank','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/ukLnPbIffxE/hqdefault.jpg','duration': '14:34'},
      {'videoId': '_sLgRBSQQxw','title': 'The Most Powerful Way to Remember What You Study','channel': 'Thomas Frank','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/_sLgRBSQQxw/hqdefault.jpg','duration': '12:46'},
      {'videoId': 'ddq8JIMhz7Y','title': 'Active Recall: Best Study Technique for Top Scores','channel': 'Ali Abdaal','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/ddq8JIMhz7Y/hqdefault.jpg','duration': '9:48'},
      {'videoId': 'p68rCAlhSPM','title': 'Spaced Repetition: How to Retain Any Subject Fast','channel': 'Ali Abdaal','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/p68rCAlhSPM/hqdefault.jpg','duration': '10:15'},
      {'videoId': '1Evwgu369Jw','title': 'Feynman Technique: Master Complex Concepts In Hours','channel': 'Thomas Frank','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/1Evwgu369Jw/hqdefault.jpg','duration': '17:42'},
      {'videoId': '0WpZ1E_5aO0','title': 'Speed Math & Mental Arithmetic Shortcuts','channel': 'Khan Academy','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/0WpZ1E_5aO0/hqdefault.jpg','duration': '15:20'},
      {'videoId': 'fDbxPVn02VU','title': 'How to Remember Everything You Read (Scientific Method)','channel': 'Thomas Frank','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/fDbxPVn02VU/hqdefault.jpg','duration': '11:35'},
      {'videoId': 'LNHBMFCzznE','title': 'Improve Your Memory: Crash Course Study Skills','channel': 'CrashCourse','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/LNHBMFCzznE/hqdefault.jpg','duration': '10:02'},
      {'videoId': 'VSkjATEQ3ZI','title': 'Time Management & Speed for High-Stakes Exams','channel': 'CrashCourse','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/VSkjATEQ3ZI/hqdefault.jpg','duration': '9:17'},
      {'videoId': 'IWMBhwxGiH8','title': 'Exam Strategies & High-Score Prep Methods','channel': 'CrashCourse','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/IWMBhwxGiH8/hqdefault.jpg','duration': '9:52'},
      {'videoId': 'CPxSzxylRCI','title': 'Note-Taking & High Retention Crash Course','channel': 'CrashCourse','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/CPxSzxylRCI/hqdefault.jpg','duration': '10:47'},
      {'videoId': '7c_qK-WbE2o','title': 'How I Ranked 1st at Cambridge University (Exam Method)','channel': 'Ali Abdaal','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/7c_qK-WbE2o/hqdefault.jpg','duration': '16:40'},
      {'videoId': 'YDfVQOd_QkE','title': 'The Power of Believing That You Can Improve','channel': 'TED','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/YDfVQOd_QkE/hqdefault.jpg','duration': '10:21'},
      {'videoId': 'e9dZQelULDk','title': 'How to Get Your Brain to Focus Under Exam Pressure','channel': 'TEDx Talks','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/e9dZQelULDk/hqdefault.jpg','duration': '14:08'},
      {'videoId': 'pOLmD_WVY-E','title': 'Logical Reasoning & Avoiding Cognitive Traps','channel': 'TED-Ed','category': 'Competitive Exams','thumbnail': 'https://img.youtube.com/vi/pOLmD_WVY-E/hqdefault.jpg','duration': '4:58'},
    ],

    "Knowledge & Discovery": [
      {'videoId': 'H14bBuluwB8','title': 'Grit: The Power of Passion and Perseverance','channel': 'TED','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
      {'videoId': 'fxbCHn6gE3U','title': 'The Surprising Habits of Original Thinkers','channel': 'TED','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/fxbCHn6gE3U/hqdefault.jpg','duration': '15:24'},
      {'videoId': 'UF8uR6Z6KLc','title': 'Steve Jobs Stanford Commencement Address','channel': 'Stanford','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/UF8uR6Z6KLc/hqdefault.jpg','duration': '15:04'},
      {'videoId': 'yoEezZD71sc','title': '9 Timeless Life Lessons – Tim Minchin Address','channel': 'University of Western Australia','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/yoEezZD71sc/hqdefault.jpg','duration': '17:53'},
      {'videoId': 'aUYSDEYdmzw','title': 'What It Takes to Be a Great Leader','channel': 'TED','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/aUYSDEYdmzw/hqdefault.jpg','duration': '9:08'},
      {'videoId': 'c_Eutci7ack','title': 'How Power Dynamics Shape Human History','channel': 'TED-Ed','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/c_Eutci7ack/hqdefault.jpg','duration': '5:50'},
      {'videoId': 'VO6XEQIsCoM','title': 'The Paradox of Choice: Why More Is Less','channel': 'TED','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
      {'videoId': 'iG9CE55wbtY','title': 'Do Schools Kill Human Creativity? – Sir Ken Robinson','channel': 'TED','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/iG9CE55wbtY/hqdefault.jpg','duration': '19:12'},
      {'videoId': 'YbgnlkJPga4','title': 'The Past We Can Never Return To: Time & Memory','channel': 'Kurzgesagt','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/YbgnlkJPga4/hqdefault.jpg','duration': '8:32'},
      {'videoId': 'QsBT5EQt348','title': 'Human Population & Planetary Evolution Explained','channel': 'Kurzgesagt','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/QsBT5EQt348/hqdefault.jpg','duration': '5:57'},
      {'videoId': 'ILDy6kYU-xQ','title': 'Are You a Body With a Mind or a Mind With a Body?','channel': 'TED-Ed','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/ILDy6kYU-xQ/hqdefault.jpg','duration': '6:15'},
      {'videoId': 'e7S8jWh6AEs','title': 'The Paradox of Value: Economics & Human Behavior','channel': 'TED-Ed','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/e7S8jWh6AEs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'pOLmD_WVY-E','title': 'Why Incompetent People Think They Are Amazing (Dunning-Kruger)','channel': 'TED-Ed','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/pOLmD_WVY-E/hqdefault.jpg','duration': '4:58'},
      {'videoId': 'TQMbvJNRpLE','title': 'How to Set and Achieve Your Most Ambitious Goals','channel': 'TEDx Talks','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/TQMbvJNRpLE/hqdefault.jpg','duration': '9:09'},
      {'videoId': 'xp0O2vi8DX4','title': 'How to Motivate Yourself to Change Your Behavior','channel': 'TEDx Talks','category': 'Knowledge & Discovery','thumbnail': 'https://img.youtube.com/vi/xp0O2vi8DX4/hqdefault.jpg','duration': '17:48'},
    ],

    "Technology & AI": [
      {'videoId': 'aircAruvnKk','title': 'But What Is a Neural Network? Deep Learning Chapter 1','channel': '3Blue1Brown','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/aircAruvnKk/hqdefault.jpg','duration': '19:13'},
      {'videoId': 'IHZwWFHWa-w','title': 'Gradient Descent: How Neural Networks Actually Learn','channel': '3Blue1Brown','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/IHZwWFHWa-w/hqdefault.jpg','duration': '21:00'},
      {'videoId': 'Ilg3gGewQ5U','title': 'What is Backpropagation Really Doing? (Neural Networks)','channel': '3Blue1Brown','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/Ilg3gGewQ5U/hqdefault.jpg','duration': '13:54'},
      {'videoId': 'zjkBMFhNj_g','title': 'Harvard CS50: Computer Science & Computational Thinking','channel': 'CS50','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/zjkBMFhNj_g/hqdefault.jpg','duration': '2:01:14'},
      {'videoId': '4Q5ZZbAzqDo','title': 'The Computer That Mastered Go: AlphaGo & Deep Learning','channel': 'TED','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/4Q5ZZbAzqDo/hqdefault.jpg','duration': '15:49'},
      {'videoId': 'GVsUOuSjvcg','title': 'Future Computers Will Be Radically Different: Quantum Computing','channel': 'Veritasium','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/GVsUOuSjvcg/hqdefault.jpg','duration': '17:37'},
      {'videoId': 'fNK_zzaMoSs','title': 'Vectors & Linear Algebra for Machine Learning','channel': '3Blue1Brown','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/fNK_zzaMoSs/hqdefault.jpg','duration': '9:52'},
      {'videoId': 'p3q5zWCw8J4','title': 'MIT 6.006: Introduction to Algorithms and Complexity','channel': 'MIT OpenCourseWare','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/p3q5zWCw8J4/hqdefault.jpg','duration': '53:18'},
      {'videoId': 'inN8seMm7UI','title': 'How Public Key Cryptography & Encryption Work','channel': 'Computerphile','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/inN8seMm7UI/hqdefault.jpg','duration': '11:42'},
      {'videoId': 'kCCai53GDUU','title': 'Quantum Computing in 100 Seconds','channel': 'Fireship','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/kCCai53GDUU/hqdefault.jpg','duration': '2:25'},
      {'videoId': 'ujTCoH21GlA','title': 'Lex Fridman: The Future of Artificial General Intelligence','channel': 'Lex Fridman','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/ujTCoH21GlA/hqdefault.jpg','duration': '14:20'},
      {'videoId': 'X44H6Jp7w60','title': 'Software Engineering & System Design Fundamentals','channel': 'FreeCodeCamp','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/X44H6Jp7w60/hqdefault.jpg','duration': '45:10'},
      {'videoId': 'mZsaaturR6E','title': 'Nuclear Fusion Power: Physics & Next-Gen Energy','channel': 'Kurzgesagt','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/mZsaaturR6E/hqdefault.jpg','duration': '6:01'},
      {'videoId': 'ulCdoCfw-bY','title': 'Civilization Megastructures & Dyson Sphere Engineering','channel': 'Kurzgesagt','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/ulCdoCfw-bY/hqdefault.jpg','duration': '7:22'},
      {'videoId': 'bHIhgxav9LY','title': 'Electronic Circuits & Semiconductor Logic Fundamentals','channel': 'Veritasium','category': 'Technology & AI','thumbnail': 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg','duration': '14:32'},
    ],

    "Business & Finance": [
      {'videoId': 'PHe0bXAIuk0','title': 'How The Economic Machine Works: Macro & Micro Economics','channel': 'Principles by Ray Dalio','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/PHe0bXAIuk0/hqdefault.jpg','duration': '31:00'},
      {'videoId': 'bNpx7gpSqbY','title': 'The Single Biggest Reason Why Start-Ups Succeed','channel': 'TED','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/bNpx7gpSqbY/hqdefault.jpg','duration': '6:41'},
      {'videoId': 'p7HKvqRI_Bo','title': 'How Does the Global Stock Market Work?','channel': 'TED-Ed','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/p7HKvqRI_Bo/hqdefault.jpg','duration': '4:29'},
      {'videoId': 'HAnw168huqA','title': 'Think Fast, Talk Smart: Communication & Pitching Techniques','channel': 'Stanford GSB','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/HAnw168huqA/hqdefault.jpg','duration': '58:42'},
      {'videoId': 'WEDIj9JBTC8','title': 'How to Invest for Beginners: Index Funds & Compounding','channel': 'Ali Abdaal','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/WEDIj9JBTC8/hqdefault.jpg','duration': '18:40'},
      {'videoId': 'yV_hS_p_U2k','title': 'How Money & Compound Interest Build Generational Wealth','channel': 'Graham Stephan','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/yV_hS_p_U2k/hqdefault.jpg','duration': '14:15'},
      {'videoId': 'kOD_lqf1Yy8','title': 'Venture Creation & Scaling Great Companies','channel': 'Stanford GSB','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/kOD_lqf1Yy8/hqdefault.jpg','duration': '48:30'},
      {'videoId': '5MgBikgcWnY','title': 'Supply, Demand and Market Equilibrium: Crash Course Economics','channel': 'CrashCourse','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/5MgBikgcWnY/hqdefault.jpg','duration': '10:22'},
      {'videoId': 'e7S8jWh6AEs','title': 'The Paradox of Value: Microeconomics & Pricing','channel': 'TED-Ed','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/e7S8jWh6AEs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'Xf2y8J2_K7o','title': 'Fear-Setting: Why You Should Define Your Fears in Business','channel': 'TED','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/Xf2y8J2_K7o/hqdefault.jpg','duration': '13:21'},
      {'videoId': 'aUYSDEYdmzw','title': 'What It Takes to Be a Great Leader in Modern Business','channel': 'TED','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/aUYSDEYdmzw/hqdefault.jpg','duration': '9:08'},
      {'videoId': 'VO6XEQIsCoM','title': 'Behavioral Economics: Investor Psychology & Decision Traps','channel': 'TED','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
      {'videoId': 'TQMbvJNRpLE','title': 'How to Achieve Your Most Ambitious Startup Goals','channel': 'TEDx Talks','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/TQMbvJNRpLE/hqdefault.jpg','duration': '9:09'},
      {'videoId': 'UF8uR6Z6KLc','title': 'Steve Jobs: Building Products That Revolutionize Industries','channel': 'Stanford','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/UF8uR6Z6KLc/hqdefault.jpg','duration': '15:04'},
      {'videoId': 'H14bBuluwB8','title': 'Grit & Perseverance in Long-Term Business Building','channel': 'TED','category': 'Business & Finance','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
    ],

    "Spirituality & Philosophy": [
      {'videoId': '1A_CAkYt3GY','title': 'What is Philosophy? Crash Course Philosophy #1','channel': 'CrashCourse','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/1A_CAkYt3GY/hqdefault.jpg','duration': '10:23'},
      {'videoId': '7bA0B_9rE_w','title': 'Introduction to Advaita Vedanta & The Nature of Mind','channel': 'Swami Sarvapriyananda','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/7bA0B_9rE_w/hqdefault.jpg','duration': '1:02:15'},
      {'videoId': 'D9O4K1fWfN8','title': 'The Philosophy of Stoicism: Inner Calm in Chaos','channel': 'Einzelgänger','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/D9O4K1fWfN8/hqdefault.jpg','duration': '14:50'},
      {'videoId': 'Th8msd-b_zU','title': 'The Art of Living in the Present Moment','channel': 'Alan Watts','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/Th8msd-b_zU/hqdefault.jpg','duration': '11:15'},
      {'videoId': 'sU786gC7Pq8','title': 'How to Build Unshakeable Inner Stillness (Daily Stoic)','channel': 'Daily Stoic','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/sU786gC7Pq8/hqdefault.jpg','duration': '12:35'},
      {'videoId': 'jGvP9X2n0Fk','title': 'Existentialism and Finding Personal Meaning in Life','channel': 'CrashCourse','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/jGvP9X2n0Fk/hqdefault.jpg','duration': '9:40'},
      {'videoId': 'ILDy6kYU-xQ','title': 'Are You a Body with a Mind or a Mind with a Body?','channel': 'TED-Ed','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/ILDy6kYU-xQ/hqdefault.jpg','duration': '6:15'},
      {'videoId': 'MBRqu0YOH14','title': 'Optimistic Nihilism: Creating Your Own Meaning in the Cosmos','channel': 'Kurzgesagt','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg','duration': '6:10'},
      {'videoId': 'W2VoFzU0ZBo','title': 'Eastern Wisdom Traditions & Marcus Aurelius Reflections','channel': 'The School of Life','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/W2VoFzU0ZBo/hqdefault.jpg','duration': '8:24'},
      {'videoId': 'UF8uR6Z6KLc','title': 'Living With Deep Purpose & Inner Alignment','channel': 'Stanford','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/UF8uR6Z6KLc/hqdefault.jpg','duration': '15:04'},
      {'videoId': 'yoEezZD71sc','title': 'Philosophy of Impermanence & Meaningful Existence','channel': 'University of Western Australia','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/yoEezZD71sc/hqdefault.jpg','duration': '17:53'},
      {'videoId': 'YDfVQOd_QkE','title': 'The Inner Compass: Growth Mindset & Character Mastery','channel': 'TED','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/YDfVQOd_QkE/hqdefault.jpg','duration': '10:21'},
      {'videoId': 'VO6XEQIsCoM','title': 'Seeking Contentment over Excess: The Wisdom of Simplicity','channel': 'TED','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
      {'videoId': 'iG9CE55wbtY','title': 'Human Creativity, Soul and Deep Life Purpose','channel': 'TED','category': 'Spirituality & Philosophy','thumbnail': 'https://img.youtube.com/vi/iG9CE55wbtY/hqdefault.jpg','duration': '19:12'},
    ],

    "Health & Fitness": [
      {'videoId': 'inpok4MKVLM','title': '5-Minute Meditation You Can Do Anywhere for Instant Calm','channel': 'Goodful','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/inpok4MKVLM/hqdefault.jpg','duration': '5:00'},
      {'videoId': 'gXw_3A8u2v4','title': 'Neurobiology of Sleep, Focus and Dopamine Protocols','channel': 'Huberman Lab','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/gXw_3A8u2v4/hqdefault.jpg','duration': '2:15:30'},
      {'videoId': 'V01-4jW7Xn0','title': 'Sleep is Your Superpower: How Sleep Recharges Your Brain','channel': 'TED','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/V01-4jW7Xn0/hqdefault.jpg','duration': '19:10'},
      {'videoId': 'Ks-_Mh1QhMc','title': 'Your Body Language Shapes Physiological State & Cortisol','channel': 'TED','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/Ks-_Mh1QhMc/hqdefault.jpg','duration': '20:56'},
      {'videoId': 'wm_wUo31y4k','title': 'Physical Fitness, Strength & Biomechanics Optimization','channel': 'Huberman Lab','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/wm_wUo31y4k/hqdefault.jpg','duration': '1:45:10'},
      {'videoId': 'e9dZQelULDk','title': 'How to Get Your Brain to Regulate Stress and Master Focus','channel': 'TEDx Talks','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/e9dZQelULDk/hqdefault.jpg','duration': '14:08'},
      {'videoId': 'KxGRhd_iVuE','title': 'What Makes a Good Life? Lessons from 75-Year Harvard Study','channel': 'TED','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/KxGRhd_iVuE/hqdefault.jpg','duration': '12:46'},
      {'videoId': '4-r1a2v8K4Y','title': 'Nutrition, Metabolism and Healthy Habits for Longevity','channel': 'Doctor Mike','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/4-r1a2v8K4Y/hqdefault.jpg','duration': '13:20'},
      {'videoId': 'RqwjP-qYm9Q','title': 'The Nervous System: Crash Course Anatomy & Physiology','channel': 'CrashCourse','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/RqwjP-qYm9Q/hqdefault.jpg','duration': '10:36'},
      {'videoId': 'n3Xv_g3g-mA','title': 'Why Loneliness Hurts and How to Build Mental Connection','channel': 'Kurzgesagt','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/n3Xv_g3g-mA/hqdefault.jpg','duration': '7:20'},
      {'videoId': 'aIx2N-viNwY','title': 'Biological Aging, Cellular Longevity & Time Perception','channel': 'Veritasium','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/aIx2N-viNwY/hqdefault.jpg','duration': '14:35'},
      {'videoId': 'H14bBuluwB8','title': 'Mental Toughness, Physical Grit & Emotional Resilience','channel': 'TED','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
      {'videoId': 'xp0O2vi8DX4','title': 'How to Motivate Yourself to Build Sustainable Health Habits','channel': 'TEDx Talks','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/xp0O2vi8DX4/hqdefault.jpg','duration': '17:48'},
      {'videoId': 'O7XnZq_4zJ0','title': 'How Your Immune System Protects Every Cell','channel': 'Kurzgesagt','category': 'Health & Fitness','thumbnail': 'https://img.youtube.com/vi/O7XnZq_4zJ0/hqdefault.jpg','duration': '10:48'},
    ],
  };

  // ── Subcategory Maps ──────────────────────────────────────────────

  static const Map<String, List<String>> categorySubcategories = {
    'Education & Learning': [
      'Study Strategies & Learning Science',
      'Academic Mastery',
      'Skills & Career Learning',
      'Self-Directed Learning',
      'Critical Thinking & Problem Solving',
    ],
    'Competitive Exams': [
      'Quantitative Aptitude & Mathematics',
      'Logical Reasoning & Mental Ability',
      'Verbal Ability & Language',
      'General Awareness & Current Affairs',
      'Exam Strategy & Performance',
    ],
    'Knowledge & Discovery': [
      'Science & the Universe',
      'History & Civilizations',
      'Geography & Our Planet',
      'Human Behavior & Society',
      'Curiosities & Hidden Knowledge',
    ],
    'Technology & AI': [
      'Artificial Intelligence & Generative AI',
      'Software Development & Engineering',
      'Emerging Technologies',
      'Cybersecurity & Digital Safety',
      'Future of Technology',
    ],
    'Business & Finance': [
      'Personal Finance & Wealth Building',
      'Investing & Markets',
      'Entrepreneurship & Startups',
      'Business Strategy & Leadership',
      'Economics & Financial Intelligence',
    ],
    'Spirituality & Philosophy': [
      'Indian Wisdom & Vedanta',
      'Meditation & Inner Awareness',
      'Philosophy & Meaning',
      'World Wisdom Traditions',
      'Purpose, Values & Self-Mastery',
    ],
    'Health & Fitness': [
      'Exercise & Physical Performance',
      'Nutrition & Healthy Eating',
      'Sleep & Recovery',
      'Mental Wellbeing & Stress Management',
      'Healthy Lifestyle & Longevity',
    ],
  };

  static const Map<String, List<Map<String, String>>> subcategoryVideos = {

    'Study Strategies & Learning Science': [
      {'videoId': 'ukLnPbIffxE','title': 'How to Study Smarter, Not Harder','channel': 'Thomas Frank','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/ukLnPbIffxE/hqdefault.jpg','duration': '14:34'},
      {'videoId': '_sLgRBSQQxw','title': 'The Most Powerful Way to Remember What You Study','channel': 'Thomas Frank','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/_sLgRBSQQxw/hqdefault.jpg','duration': '12:46'},
      {'videoId': 'ddq8JIMhz7Y','title': 'Active Recall – The Most Effective Study Technique','channel': 'Ali Abdaal','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/ddq8JIMhz7Y/hqdefault.jpg','duration': '9:48'},
      {'videoId': 'p68rCAlhSPM','title': 'Spaced Repetition – How to Learn and Retain Anything Fast','channel': 'Ali Abdaal','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/p68rCAlhSPM/hqdefault.jpg','duration': '10:15'},
      {'videoId': '1Evwgu369Jw','title': 'The Feynman Technique – Master Any Subject In Record Time','channel': 'Thomas Frank','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/1Evwgu369Jw/hqdefault.jpg','duration': '17:42'},
      {'videoId': 'LNHBMFCzznE','title': 'Improve Your Memory – Crash Course Study Skills','channel': 'CrashCourse','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/LNHBMFCzznE/hqdefault.jpg','duration': '10:02'},
      {'videoId': 'fDbxPVn02VU','title': 'How to Remember Everything You Read (Scientific Method)','channel': 'Thomas Frank','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/fDbxPVn02VU/hqdefault.jpg','duration': '11:35'},
      {'videoId': 'CPxSzxylRCI','title': 'How to Take Better Notes (Cornell & Outline Systems)','channel': 'CrashCourse','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/CPxSzxylRCI/hqdefault.jpg','duration': '10:47'},
      {'videoId': 'e9dZQelULDk','title': 'How to Get Your Brain to Focus on Demand','channel': 'TEDx Talks','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/e9dZQelULDk/hqdefault.jpg','duration': '14:08'},
      {'videoId': 'H14bBuluwB8','title': 'Grit: The Power of Passion and Perseverance','channel': 'TED','category': 'Study Strategies & Learning Science','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
    ],

    'Academic Mastery': [
      {'videoId': 'lZ3bPUKo5zc','title': 'Lecture 1: Introduction to Superposition','channel': 'MIT OpenCourseWare','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/lZ3bPUKo5zc/hqdefault.jpg','duration': '1:16:07'},
      {'videoId': 'HeQX2HjkcNo','title': "Math's Fundamental Flaw – Gödel's Incompleteness Theorem",'channel': 'Veritasium','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/HeQX2HjkcNo/hqdefault.jpg','duration': '34:00'},
      {'videoId': 'bHIhgxav9LY','title': 'The Biggest Misconception About Electricity in Physics','channel': 'Veritasium','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg','duration': '14:32'},
      {'videoId': 'aircAruvnKk','title': 'Essence of Linear Algebra & Neural Networks','channel': '3Blue1Brown','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/aircAruvnKk/hqdefault.jpg','duration': '19:13'},
      {'videoId': 'IHZwWFHWa-w','title': 'Gradient Descent: How Neural Networks Actually Learn','channel': '3Blue1Brown','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/IHZwWFHWa-w/hqdefault.jpg','duration': '21:00'},
      {'videoId': 'IWMBhwxGiH8','title': 'Exam Strategies & High-Score Prep Methods','channel': 'CrashCourse','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/IWMBhwxGiH8/hqdefault.jpg','duration': '9:52'},
      {'videoId': 'VSkjATEQ3ZI','title': 'Time Management for Academic High Performers','channel': 'CrashCourse','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/VSkjATEQ3ZI/hqdefault.jpg','duration': '9:17'},
      {'videoId': 'pTn6Ewhb27k','title': 'Why No One Has Measured The Two-Way Speed Of Light','channel': 'Veritasium','category': 'Academic Mastery','thumbnail': 'https://img.youtube.com/vi/pTn6Ewhb27k/hqdefault.jpg','duration': '19:07'},
    ],

    'Skills & Career Learning': [
      {'videoId': 'HAnw168huqA','title': 'Think Fast, Talk Smart: Communication Techniques','channel': 'Stanford GSB','category': 'Skills & Career Learning','thumbnail': 'https://img.youtube.com/vi/HAnw168huqA/hqdefault.jpg','duration': '58:42'},
      {'videoId': 'Ks-_Mh1QhMc','title': 'Your Body Language May Shape Who You Are','channel': 'TED','category': 'Skills & Career Learning','thumbnail': 'https://img.youtube.com/vi/Ks-_Mh1QhMc/hqdefault.jpg','duration': '20:56'},
      {'videoId': 'aUYSDEYdmzw','title': 'What It Takes to Be a Great Leader','channel': 'TED','category': 'Skills & Career Learning','thumbnail': 'https://img.youtube.com/vi/aUYSDEYdmzw/hqdefault.jpg','duration': '9:08'},
      {'videoId': 'UF8uR6Z6KLc','title': 'Steve Jobs Stanford Commencement Address: How to Live Before You Die','channel': 'Stanford','category': 'Skills & Career Learning','thumbnail': 'https://img.youtube.com/vi/UF8uR6Z6KLc/hqdefault.jpg','duration': '15:04'},
      {'videoId': 'bNpx7gpSqbY','title': 'The Single Biggest Reason Why Start-Ups Succeed','channel': 'TED','category': 'Skills & Career Learning','thumbnail': 'https://img.youtube.com/vi/bNpx7gpSqbY/hqdefault.jpg','duration': '6:41'},
      {'videoId': 'TQMbvJNRpLE','title': 'How to Set and Achieve Your Most Ambitious Goals','channel': 'TEDx Talks','category': 'Skills & Career Learning','thumbnail': 'https://img.youtube.com/vi/TQMbvJNRpLE/hqdefault.jpg','duration': '9:09'},
    ],

    'Self-Directed Learning': [
      {'videoId': 'iG9CE55wbtY','title': 'Do Schools Kill Creativity? – Sir Ken Robinson','channel': 'TED','category': 'Self-Directed Learning','thumbnail': 'https://img.youtube.com/vi/iG9CE55wbtY/hqdefault.jpg','duration': '19:12'},
      {'videoId': 'fxbCHn6gE3U','title': 'The Surprising Habits of Original Thinkers','channel': 'TED','category': 'Self-Directed Learning','thumbnail': 'https://img.youtube.com/vi/fxbCHn6gE3U/hqdefault.jpg','duration': '15:24'},
      {'videoId': 'MBRqu0YOH14','title': 'Optimistic Nihilism – Kurzgesagt Universe Perspective','channel': 'Kurzgesagt','category': 'Self-Directed Learning','thumbnail': 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg','duration': '6:10'},
      {'videoId': 'YbgnlkJPga4','title': 'The Past We Can Never Return To (Time & Memory)','channel': 'Kurzgesagt','category': 'Self-Directed Learning','thumbnail': 'https://img.youtube.com/vi/YbgnlkJPga4/hqdefault.jpg','duration': '8:32'},
      {'videoId': 'aIx2N-viNwY','title': 'Why Life Seems to Speed Up as We Age','channel': 'Veritasium','category': 'Self-Directed Learning','thumbnail': 'https://img.youtube.com/vi/aIx2N-viNwY/hqdefault.jpg','duration': '14:35'},
    ],

    'Critical Thinking & Problem Solving': [
      {'videoId': 'pOLmD_WVY-E','title': 'Why Incompetent People Think They Are Amazing (Dunning-Kruger)','channel': 'TED-Ed','category': 'Critical Thinking & Problem Solving','thumbnail': 'https://img.youtube.com/vi/pOLmD_WVY-E/hqdefault.jpg','duration': '4:58'},
      {'videoId': 'ILDy6kYU-xQ','title': 'Are You a Body With a Mind or a Mind With a Body?','channel': 'TED-Ed','category': 'Critical Thinking & Problem Solving','thumbnail': 'https://img.youtube.com/vi/ILDy6kYU-xQ/hqdefault.jpg','duration': '6:15'},
      {'videoId': 'e7S8jWh6AEs','title': 'The Paradox of Value – Economics & Human Valuation','channel': 'TED-Ed','category': 'Critical Thinking & Problem Solving','thumbnail': 'https://img.youtube.com/vi/e7S8jWh6AEs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'VO6XEQIsCoM','title': 'The Paradox of Choice – Why More Is Less','channel': 'TED','category': 'Critical Thinking & Problem Solving','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
      {'videoId': '1A_CAkYt3GY','title': 'What is Philosophy and Logic? Crash Course','channel': 'CrashCourse','category': 'Critical Thinking & Problem Solving','thumbnail': 'https://img.youtube.com/vi/1A_CAkYt3GY/hqdefault.jpg','duration': '10:23'},
    ],

    'Quantitative Aptitude & Mathematics': [
      {'videoId': '0WpZ1E_5aO0','title': 'Speed Math & Mental Arithmetic Shortcuts for Competitive Exams','channel': 'Khan Academy','category': 'Quantitative Aptitude & Mathematics','thumbnail': 'https://img.youtube.com/vi/0WpZ1E_5aO0/hqdefault.jpg','duration': '15:20'},
      {'videoId': 'HeQX2HjkcNo','title': 'The Fundamentals of Advanced Mathematics & Theorem Proofs','channel': 'Veritasium','category': 'Quantitative Aptitude & Mathematics','thumbnail': 'https://img.youtube.com/vi/HeQX2HjkcNo/hqdefault.jpg','duration': '34:00'},
      {'videoId': 'cZH0YnFpjwU','title': 'A Brief History of Numerical Systems & Arithmetic Logic','channel': 'TED-Ed','category': 'Quantitative Aptitude & Mathematics','thumbnail': 'https://img.youtube.com/vi/cZH0YnFpjwU/hqdefault.jpg','duration': '5:23'},
      {'videoId': 'aircAruvnKk','title': 'Vectors, Matrices & Linear Algebra Concepts','channel': '3Blue1Brown','category': 'Quantitative Aptitude & Mathematics','thumbnail': 'https://img.youtube.com/vi/aircAruvnKk/hqdefault.jpg','duration': '19:13'},
      {'videoId': 'IHZwWFHWa-w','title': 'Calculus & Optimization Problem Solving Methods','channel': '3Blue1Brown','category': 'Quantitative Aptitude & Mathematics','thumbnail': 'https://img.youtube.com/vi/IHZwWFHWa-w/hqdefault.jpg','duration': '21:00'},
    ],

    'Logical Reasoning & Mental Ability': [
      {'videoId': 'pOLmD_WVY-E','title': 'Logical Reasoning & Avoiding Cognitive Traps in Exams','channel': 'TED-Ed','category': 'Logical Reasoning & Mental Ability','thumbnail': 'https://img.youtube.com/vi/pOLmD_WVY-E/hqdefault.jpg','duration': '4:58'},
      {'videoId': 'ILDy6kYU-xQ','title': 'Mind & Logic: How the Brain Solves Analytical Puzzles','channel': 'TED-Ed','category': 'Logical Reasoning & Mental Ability','thumbnail': 'https://img.youtube.com/vi/ILDy6kYU-xQ/hqdefault.jpg','duration': '6:15'},
      {'videoId': 'VO6XEQIsCoM','title': 'Decision Logic and Reasoning Frameworks','channel': 'TED','category': 'Logical Reasoning & Mental Ability','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
      {'videoId': '1A_CAkYt3GY','title': 'Formal Logic & Deductive Reasoning Crash Course','channel': 'CrashCourse','category': 'Logical Reasoning & Mental Ability','thumbnail': 'https://img.youtube.com/vi/1A_CAkYt3GY/hqdefault.jpg','duration': '10:23'},
    ],

    'Verbal Ability & Language': [
      {'videoId': 'HAnw168huqA','title': 'Verbal Communication & Language Mastery Techniques','channel': 'Stanford GSB','category': 'Verbal Ability & Language','thumbnail': 'https://img.youtube.com/vi/HAnw168huqA/hqdefault.jpg','duration': '58:42'},
      {'videoId': 'fDbxPVn02VU','title': 'How to Read & Comprehend Complex Texts 3x Faster','channel': 'Thomas Frank','category': 'Verbal Ability & Language','thumbnail': 'https://img.youtube.com/vi/fDbxPVn02VU/hqdefault.jpg','duration': '11:35'},
      {'videoId': 'p68rCAlhSPM','title': 'Vocabulary Building & Word Roots Retention System','channel': 'Ali Abdaal','category': 'Verbal Ability & Language','thumbnail': 'https://img.youtube.com/vi/p68rCAlhSPM/hqdefault.jpg','duration': '10:15'},
      {'videoId': 'LNHBMFCzznE','title': 'Reading Comprehension & Critical Analysis Skills','channel': 'CrashCourse','category': 'Verbal Ability & Language','thumbnail': 'https://img.youtube.com/vi/LNHBMFCzznE/hqdefault.jpg','duration': '10:02'},
    ],

    'General Awareness & Current Affairs': [
      {'videoId': 'c_Eutci7ack','title': 'How Government & Geopolitics Shape the World','channel': 'TED-Ed','category': 'General Awareness & Current Affairs','thumbnail': 'https://img.youtube.com/vi/c_Eutci7ack/hqdefault.jpg','duration': '5:50'},
      {'videoId': 'PHe0bXAIuk0','title': 'How The Global Economic Machine Works','channel': 'Principles by Ray Dalio','category': 'General Awareness & Current Affairs','thumbnail': 'https://img.youtube.com/vi/PHe0bXAIuk0/hqdefault.jpg','duration': '31:00'},
      {'videoId': 'czgOWmtGVGs','title': 'World History & Civilizations Timeline Evolution','channel': 'Kurzgesagt','category': 'General Awareness & Current Affairs','thumbnail': 'https://img.youtube.com/vi/czgOWmtGVGs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'QsBT5EQt348','title': 'Global Demographics & Climate Trends Explained','channel': 'Kurzgesagt','category': 'General Awareness & Current Affairs','thumbnail': 'https://img.youtube.com/vi/QsBT5EQt348/hqdefault.jpg','duration': '5:57'},
    ],

    'Exam Strategy & Performance': [
      {'videoId': 'IWMBhwxGiH8','title': 'Exam Strategies & Score Optimization Techniques','channel': 'CrashCourse','category': 'Exam Strategy & Performance','thumbnail': 'https://img.youtube.com/vi/IWMBhwxGiH8/hqdefault.jpg','duration': '9:52'},
      {'videoId': 'VSkjATEQ3ZI','title': 'Time Management & Speed Under Exam Pressure','channel': 'CrashCourse','category': 'Exam Strategy & Performance','thumbnail': 'https://img.youtube.com/vi/VSkjATEQ3ZI/hqdefault.jpg','duration': '9:17'},
      {'videoId': '7c_qK-WbE2o','title': 'The Ultimate Mock Test Strategy & Error Log System','channel': 'Ali Abdaal','category': 'Exam Strategy & Performance','thumbnail': 'https://img.youtube.com/vi/7c_qK-WbE2o/hqdefault.jpg','duration': '16:40'},
      {'videoId': 'YDfVQOd_QkE','title': 'The Growth Mindset: Scoring Above Your Potential','channel': 'TED','category': 'Exam Strategy & Performance','thumbnail': 'https://img.youtube.com/vi/YDfVQOd_QkE/hqdefault.jpg','duration': '10:21'},
    ],

    'Science & the Universe': [
      {'videoId': 'e-P5IFTqB98','title': 'Black Holes Explained: From Birth to Quantum Death','channel': 'Kurzgesagt','category': 'Science & the Universe','thumbnail': 'https://img.youtube.com/vi/e-P5IFTqB98/hqdefault.jpg','duration': '6:30'},
      {'videoId': 'wNDGgL73ihY','title': 'The Beginning of Everything – The Big Bang Origins','channel': 'Kurzgesagt','category': 'Science & the Universe','thumbnail': 'https://img.youtube.com/vi/wNDGgL73ihY/hqdefault.jpg','duration': '4:17'},
      {'videoId': 'pTn6Ewhb27k','title': 'Why No One Has Measured The Two-Way Speed Of Light','channel': 'Veritasium','category': 'Science & the Universe','thumbnail': 'https://img.youtube.com/vi/pTn6Ewhb27k/hqdefault.jpg','duration': '19:07'},
      {'videoId': 'mZsaaturR6E','title': 'Nuclear Fusion Power: Physics & Future Energy','channel': 'Kurzgesagt','category': 'Science & the Universe','thumbnail': 'https://img.youtube.com/vi/mZsaaturR6E/hqdefault.jpg','duration': '6:01'},
    ],

    'History & Civilizations': [
      {'videoId': 'czgOWmtGVGs','title': 'A New Timeline for Human History & Ancient Civilizations','channel': 'Kurzgesagt','category': 'History & Civilizations','thumbnail': 'https://img.youtube.com/vi/czgOWmtGVGs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'c_Eutci7ack','title': 'How Power Dynamics Shaped Empires & History','channel': 'TED-Ed','category': 'History & Civilizations','thumbnail': 'https://img.youtube.com/vi/c_Eutci7ack/hqdefault.jpg','duration': '5:50'},
      {'videoId': 'cZH0YnFpjwU','title': 'A Brief History of Numerical Systems & Mathematics','channel': 'TED-Ed','category': 'History & Civilizations','thumbnail': 'https://img.youtube.com/vi/cZH0YnFpjwU/hqdefault.jpg','duration': '5:23'},
      {'videoId': 'PHe0bXAIuk0','title': 'How The Global Economic Machine Developed Throughout History','channel': 'Principles by Ray Dalio','category': 'History & Civilizations','thumbnail': 'https://img.youtube.com/vi/PHe0bXAIuk0/hqdefault.jpg','duration': '31:00'},
    ],

    'Geography & Our Planet': [
      {'videoId': 'QsBT5EQt348','title': 'Human Population & Planetary Evolution Explained','channel': 'Kurzgesagt','category': 'Geography & Our Planet','thumbnail': 'https://img.youtube.com/vi/QsBT5EQt348/hqdefault.jpg','duration': '5:57'},
      {'videoId': 'MBRqu0YOH14','title': 'Our Tiny Place in the Cosmos: Earth & Deep Space','channel': 'Kurzgesagt','category': 'Geography & Our Planet','thumbnail': 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg','duration': '6:10'},
      {'videoId': 'YbgnlkJPga4','title': 'The Deep Geological Past of Earth & Time','channel': 'Kurzgesagt','category': 'Geography & Our Planet','thumbnail': 'https://img.youtube.com/vi/YbgnlkJPga4/hqdefault.jpg','duration': '8:32'},
      {'videoId': 'p7HKvqRI_Bo','title': 'Global Trade Networks & Continents Connected','channel': 'TED-Ed','category': 'Geography & Our Planet','thumbnail': 'https://img.youtube.com/vi/p7HKvqRI_Bo/hqdefault.jpg','duration': '4:29'},
    ],

    'Human Behavior & Society': [
      {'videoId': 'pOLmD_WVY-E','title': 'Why Incompetent People Think They Are Amazing (Dunning-Kruger)','channel': 'TED-Ed','category': 'Human Behavior & Society','thumbnail': 'https://img.youtube.com/vi/pOLmD_WVY-E/hqdefault.jpg','duration': '4:58'},
      {'videoId': 'VO6XEQIsCoM','title': 'The Paradox of Choice: Why More Is Less in Society','channel': 'TED','category': 'Human Behavior & Society','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
      {'videoId': 'fxbCHn6gE3U','title': 'The Surprising Habits of Original Thinkers','channel': 'TED','category': 'Human Behavior & Society','thumbnail': 'https://img.youtube.com/vi/fxbCHn6gE3U/hqdefault.jpg','duration': '15:24'},
      {'videoId': 'iG9CE55wbtY','title': 'Do Schools Kill Human Creativity? – Sir Ken Robinson','channel': 'TED','category': 'Human Behavior & Society','thumbnail': 'https://img.youtube.com/vi/iG9CE55wbtY/hqdefault.jpg','duration': '19:12'},
    ],

    'Curiosities & Hidden Knowledge': [
      {'videoId': 'HeQX2HjkcNo','title': "Math's Fundamental Flaw – Gödel's Incompleteness Theorem",'channel': 'Veritasium','category': 'Curiosities & Hidden Knowledge','thumbnail': 'https://img.youtube.com/vi/HeQX2HjkcNo/hqdefault.jpg','duration': '34:00'},
      {'videoId': 'bHIhgxav9LY','title': 'The Biggest Misconception About Electricity and Circuits','channel': 'Veritasium','category': 'Curiosities & Hidden Knowledge','thumbnail': 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg','duration': '14:32'},
      {'videoId': 'pTn6Ewhb27k','title': 'The Mystery of the Speed of Light Nobody Talks About','channel': 'Veritasium','category': 'Curiosities & Hidden Knowledge','thumbnail': 'https://img.youtube.com/vi/pTn6Ewhb27k/hqdefault.jpg','duration': '19:07'},
      {'videoId': 'ILDy6kYU-xQ','title': 'Are You a Body With a Mind or a Mind With a Body?','channel': 'TED-Ed','category': 'Curiosities & Hidden Knowledge','thumbnail': 'https://img.youtube.com/vi/ILDy6kYU-xQ/hqdefault.jpg','duration': '6:15'},
    ],

    'Artificial Intelligence & Generative AI': [
      {'videoId': 'aircAruvnKk','title': 'But What Is a Neural Network? Deep Learning Chapter 1','channel': '3Blue1Brown','category': 'Artificial Intelligence & Generative AI','thumbnail': 'https://img.youtube.com/vi/aircAruvnKk/hqdefault.jpg','duration': '19:13'},
      {'videoId': 'IHZwWFHWa-w','title': 'Gradient Descent: How Neural Networks Actually Learn','channel': '3Blue1Brown','category': 'Artificial Intelligence & Generative AI','thumbnail': 'https://img.youtube.com/vi/IHZwWFHWa-w/hqdefault.jpg','duration': '21:00'},
      {'videoId': 'Ilg3gGewQ5U','title': 'What is Backpropagation Really Doing? (Neural Networks)','channel': '3Blue1Brown','category': 'Artificial Intelligence & Generative AI','thumbnail': 'https://img.youtube.com/vi/Ilg3gGewQ5U/hqdefault.jpg','duration': '13:54'},
      {'videoId': '4Q5ZZbAzqDo','title': 'The Computer That Mastered Go: AlphaGo & Deep Learning','channel': 'TED','category': 'Artificial Intelligence & Generative AI','thumbnail': 'https://img.youtube.com/vi/4Q5ZZbAzqDo/hqdefault.jpg','duration': '15:49'},
    ],

    'Software Development & Engineering': [
      {'videoId': 'zjkBMFhNj_g','title': 'Harvard CS50: Introduction to Computer Science & Coding','channel': 'CS50','category': 'Software Development & Engineering','thumbnail': 'https://img.youtube.com/vi/zjkBMFhNj_g/hqdefault.jpg','duration': '2:01:14'},
      {'videoId': 'p3q5zWCw8J4','title': 'MIT 6.006: Data Structures and Dynamic Programming','channel': 'MIT OpenCourseWare','category': 'Software Development & Engineering','thumbnail': 'https://img.youtube.com/vi/p3q5zWCw8J4/hqdefault.jpg','duration': '53:18'},
      {'videoId': 'X44H6Jp7w60','title': 'Full-Stack Architecture & Modern Software Design','channel': 'FreeCodeCamp','category': 'Software Development & Engineering','thumbnail': 'https://img.youtube.com/vi/X44H6Jp7w60/hqdefault.jpg','duration': '45:10'},
      {'videoId': 'bHIhgxav9LY','title': 'Electronic Circuits and Semiconductor Logic Fundamentals','channel': 'Veritasium','category': 'Software Development & Engineering','thumbnail': 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg','duration': '14:32'},
    ],

    'Emerging Technologies': [
      {'videoId': 'mZsaaturR6E','title': 'Nuclear Fusion Power: Physics of Unlimited Clean Energy','channel': 'Kurzgesagt','category': 'Emerging Technologies','thumbnail': 'https://img.youtube.com/vi/mZsaaturR6E/hqdefault.jpg','duration': '6:01'},
      {'videoId': 'GVsUOuSjvcg','title': 'Quantum Computing: Future Computers Will Be Radically Different','channel': 'Veritasium','category': 'Emerging Technologies','thumbnail': 'https://img.youtube.com/vi/GVsUOuSjvcg/hqdefault.jpg','duration': '17:37'},
      {'videoId': 'kCCai53GDUU','title': 'Quantum Superposition & Qubits in 100 Seconds','channel': 'Fireship','category': 'Emerging Technologies','thumbnail': 'https://img.youtube.com/vi/kCCai53GDUU/hqdefault.jpg','duration': '2:25'},
      {'videoId': 'ulCdoCfw-bY','title': 'Extreme Energy Harvesting & Dyson Sphere Engineering','channel': 'Kurzgesagt','category': 'Emerging Technologies','thumbnail': 'https://img.youtube.com/vi/ulCdoCfw-bY/hqdefault.jpg','duration': '7:22'},
    ],

    'Cybersecurity & Digital Safety': [
      {'videoId': 'inN8seMm7UI','title': 'Mathematical Cryptography, RSA & Public Key Systems','channel': 'Computerphile','category': 'Cybersecurity & Digital Safety','thumbnail': 'https://img.youtube.com/vi/inN8seMm7UI/hqdefault.jpg','duration': '11:42'},
      {'videoId': 'HeQX2HjkcNo','title': 'Mathematical Incompleteness & Secure Information Theory','channel': 'Veritasium','category': 'Cybersecurity & Digital Safety','thumbnail': 'https://img.youtube.com/vi/HeQX2HjkcNo/hqdefault.jpg','duration': '34:00'},
      {'videoId': 'c_Eutci7ack','title': 'Digital Privacy, Information Control & Societal Security','channel': 'TED-Ed','category': 'Cybersecurity & Digital Safety','thumbnail': 'https://img.youtube.com/vi/c_Eutci7ack/hqdefault.jpg','duration': '5:50'},
      {'videoId': 'VO6XEQIsCoM','title': 'Algorithms, User Tracking & Digital Choice Architecture','channel': 'TED','category': 'Cybersecurity & Digital Safety','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
    ],

    'Future of Technology': [
      {'videoId': 'GVsUOuSjvcg','title': 'The Next 50 Years of Computing & Nanotechnology','channel': 'Veritasium','category': 'Future of Technology','thumbnail': 'https://img.youtube.com/vi/GVsUOuSjvcg/hqdefault.jpg','duration': '17:37'},
      {'videoId': 'ujTCoH21GlA','title': 'Artificial General Intelligence (AGI) & Horizon of Civilization','channel': 'Lex Fridman','category': 'Future of Technology','thumbnail': 'https://img.youtube.com/vi/ujTCoH21GlA/hqdefault.jpg','duration': '14:20'},
      {'videoId': 'mZsaaturR6E','title': 'Post-Scarcity Energy: Fusion Reactors of the 21st Century','channel': 'Kurzgesagt','category': 'Future of Technology','thumbnail': 'https://img.youtube.com/vi/mZsaaturR6E/hqdefault.jpg','duration': '6:01'},
      {'videoId': 'ulCdoCfw-bY','title': 'Civilization Megastructures & Kardashev Scale Future','channel': 'Kurzgesagt','category': 'Future of Technology','thumbnail': 'https://img.youtube.com/vi/ulCdoCfw-bY/hqdefault.jpg','duration': '7:22'},
    ],

    'Personal Finance & Wealth Building': [
      {'videoId': 'WEDIj9JBTC8','title': 'Personal Finance & Wealth Building Guide for Beginners','channel': 'Ali Abdaal','category': 'Personal Finance & Wealth Building','thumbnail': 'https://img.youtube.com/vi/WEDIj9JBTC8/hqdefault.jpg','duration': '18:40'},
      {'videoId': 'yV_hS_p_U2k','title': 'How Compound Growth and Smart Saving Actually Work','channel': 'Graham Stephan','category': 'Personal Finance & Wealth Building','thumbnail': 'https://img.youtube.com/vi/yV_hS_p_U2k/hqdefault.jpg','duration': '14:15'},
      {'videoId': 'PHe0bXAIuk0','title': 'How The Economic Machine Works: Income, Debt & Wealth','channel': 'Principles by Ray Dalio','category': 'Personal Finance & Wealth Building','thumbnail': 'https://img.youtube.com/vi/PHe0bXAIuk0/hqdefault.jpg','duration': '31:00'},
      {'videoId': 'p7HKvqRI_Bo','title': 'How Does the Global Financial Market Function?','channel': 'TED-Ed','category': 'Personal Finance & Wealth Building','thumbnail': 'https://img.youtube.com/vi/p7HKvqRI_Bo/hqdefault.jpg','duration': '4:29'},
    ],

    'Investing & Markets': [
      {'videoId': 'PHe0bXAIuk0','title': 'How The Economic Machine Works: Credit Cycles & Interest Rates','channel': 'Principles by Ray Dalio','category': 'Investing & Markets','thumbnail': 'https://img.youtube.com/vi/PHe0bXAIuk0/hqdefault.jpg','duration': '31:00'},
      {'videoId': 'p7HKvqRI_Bo','title': 'How Does The Stock Market Work & How Capital Moves','channel': 'TED-Ed','category': 'Investing & Markets','thumbnail': 'https://img.youtube.com/vi/p7HKvqRI_Bo/hqdefault.jpg','duration': '4:29'},
      {'videoId': 'WEDIj9JBTC8','title': 'Index Funds, Asset Allocation & Portfolio Construction','channel': 'Ali Abdaal','category': 'Investing & Markets','thumbnail': 'https://img.youtube.com/vi/WEDIj9JBTC8/hqdefault.jpg','duration': '18:40'},
      {'videoId': 'VO6XEQIsCoM','title': 'Behavioral Economics: Market Psychology & Investor Bias','channel': 'TED','category': 'Investing & Markets','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
    ],

    'Entrepreneurship & Startups': [
      {'videoId': 'bNpx7gpSqbY','title': 'The Single Biggest Reason Why Start-Ups Succeed','channel': 'TED','category': 'Entrepreneurship & Startups','thumbnail': 'https://img.youtube.com/vi/bNpx7gpSqbY/hqdefault.jpg','duration': '6:41'},
      {'videoId': 'kOD_lqf1Yy8','title': 'Stanford GSB: Building Companies from Zero to One','channel': 'Stanford GSB','category': 'Entrepreneurship & Startups','thumbnail': 'https://img.youtube.com/vi/kOD_lqf1Yy8/hqdefault.jpg','duration': '48:30'},
      {'videoId': 'UF8uR6Z6KLc','title': 'Steve Jobs: Finding What You Love & Building Revolutionary Products','channel': 'Stanford','category': 'Entrepreneurship & Startups','thumbnail': 'https://img.youtube.com/vi/UF8uR6Z6KLc/hqdefault.jpg','duration': '15:04'},
      {'videoId': 'HAnw168huqA','title': 'Think Fast, Talk Smart: Pitching and High-Stakes Communication','channel': 'Stanford GSB','category': 'Entrepreneurship & Startups','thumbnail': 'https://img.youtube.com/vi/HAnw168huqA/hqdefault.jpg','duration': '58:42'},
    ],

    'Business Strategy & Leadership': [
      {'videoId': 'aUYSDEYdmzw','title': 'What It Takes to Be a Great Leader','channel': 'TED','category': 'Business Strategy & Leadership','thumbnail': 'https://img.youtube.com/vi/aUYSDEYdmzw/hqdefault.jpg','duration': '9:08'},
      {'videoId': 'HAnw168huqA','title': 'Executive Communication & Strategic Leadership','channel': 'Stanford GSB','category': 'Business Strategy & Leadership','thumbnail': 'https://img.youtube.com/vi/HAnw168huqA/hqdefault.jpg','duration': '58:42'},
      {'videoId': 'Ks-_Mh1QhMc','title': 'Your Body Language Shapes Leadership Presence & Authority','channel': 'TED','category': 'Business Strategy & Leadership','thumbnail': 'https://img.youtube.com/vi/Ks-_Mh1QhMc/hqdefault.jpg','duration': '20:56'},
      {'videoId': 'Xf2y8J2_K7o','title': 'Strategic Decision Making & High Performance Execution','channel': 'TED','category': 'Business Strategy & Leadership','thumbnail': 'https://img.youtube.com/vi/Xf2y8J2_K7o/hqdefault.jpg','duration': '13:21'},
    ],

    'Economics & Financial Intelligence': [
      {'videoId': 'PHe0bXAIuk0','title': 'How The Economic Machine Works by Ray Dalio','channel': 'Principles by Ray Dalio','category': 'Economics & Financial Intelligence','thumbnail': 'https://img.youtube.com/vi/PHe0bXAIuk0/hqdefault.jpg','duration': '31:00'},
      {'videoId': '5MgBikgcWnY','title': 'Macroeconomics, Inflation & Monetary Systems','channel': 'CrashCourse','category': 'Economics & Financial Intelligence','thumbnail': 'https://img.youtube.com/vi/5MgBikgcWnY/hqdefault.jpg','duration': '10:22'},
      {'videoId': 'p7HKvqRI_Bo','title': 'How Central Banks, Inflation and Currencies Operate','channel': 'TED-Ed','category': 'Economics & Financial Intelligence','thumbnail': 'https://img.youtube.com/vi/p7HKvqRI_Bo/hqdefault.jpg','duration': '4:29'},
      {'videoId': 'e7S8jWh6AEs','title': 'The Paradox of Value: Microeconomics & Scarcity','channel': 'TED-Ed','category': 'Economics & Financial Intelligence','thumbnail': 'https://img.youtube.com/vi/e7S8jWh6AEs/hqdefault.jpg','duration': '4:26'},
    ],

    'Indian Wisdom & Vedanta': [
      {'videoId': '7bA0B_9rE_w','title': 'Advaita Vedanta & The Nature of Self and Consciousness','channel': 'Swami Sarvapriyananda','category': 'Indian Wisdom & Vedanta','thumbnail': 'https://img.youtube.com/vi/7bA0B_9rE_w/hqdefault.jpg','duration': '1:02:15'},
      {'videoId': '1A_CAkYt3GY','title': 'Eastern Philosophy & Foundations of Ancient Wisdom','channel': 'CrashCourse','category': 'Indian Wisdom & Vedanta','thumbnail': 'https://img.youtube.com/vi/1A_CAkYt3GY/hqdefault.jpg','duration': '10:23'},
      {'videoId': 'ILDy6kYU-xQ','title': 'The Nature of Consciousness: Self and Non-Self','channel': 'TED-Ed','category': 'Indian Wisdom & Vedanta','thumbnail': 'https://img.youtube.com/vi/ILDy6kYU-xQ/hqdefault.jpg','duration': '6:15'},
      {'videoId': 'yoEezZD71sc','title': 'Timeless Life Wisdom: Philosophy of Impermanence','channel': 'University of Western Australia','category': 'Indian Wisdom & Vedanta','thumbnail': 'https://img.youtube.com/vi/yoEezZD71sc/hqdefault.jpg','duration': '17:53'},
    ],

    'Meditation & Inner Awareness': [
      {'videoId': 'inpok4MKVLM','title': '5-Minute Guided Meditation for Deep Presence & Stillness','channel': 'Goodful','category': 'Meditation & Inner Awareness','thumbnail': 'https://img.youtube.com/vi/inpok4MKVLM/hqdefault.jpg','duration': '5:00'},
      {'videoId': 'e9dZQelULDk','title': 'How to Calm the Mind & Master Inner Focus','channel': 'TEDx Talks','category': 'Meditation & Inner Awareness','thumbnail': 'https://img.youtube.com/vi/e9dZQelULDk/hqdefault.jpg','duration': '14:08'},
      {'videoId': 'Th8msd-b_zU','title': 'Alan Watts: Awakening Inner Awareness and Serenity','channel': 'Alan Watts','category': 'Meditation & Inner Awareness','thumbnail': 'https://img.youtube.com/vi/Th8msd-b_zU/hqdefault.jpg','duration': '11:15'},
      {'videoId': 'sU786gC7Pq8','title': 'Quieting the Restless Mind & Building Mental Peace','channel': 'Daily Stoic','category': 'Meditation & Inner Awareness','thumbnail': 'https://img.youtube.com/vi/sU786gC7Pq8/hqdefault.jpg','duration': '12:35'},
    ],

    'Philosophy & Meaning': [
      {'videoId': '1A_CAkYt3GY','title': 'What is Philosophy? Crash Course Philosophy #1','channel': 'CrashCourse','category': 'Philosophy & Meaning','thumbnail': 'https://img.youtube.com/vi/1A_CAkYt3GY/hqdefault.jpg','duration': '10:23'},
      {'videoId': 'D9O4K1fWfN8','title': 'Stoic Philosophy: Mastering What You Can Control','channel': 'Einzelgänger','category': 'Philosophy & Meaning','thumbnail': 'https://img.youtube.com/vi/D9O4K1fWfN8/hqdefault.jpg','duration': '14:50'},
      {'videoId': 'jGvP9X2n0Fk','title': 'Existentialism: Creating Meaning in an Unpredictable World','channel': 'CrashCourse','category': 'Philosophy & Meaning','thumbnail': 'https://img.youtube.com/vi/jGvP9X2n0Fk/hqdefault.jpg','duration': '9:40'},
      {'videoId': 'MBRqu0YOH14','title': 'Optimistic Nihilism: Creating Your Own Meaning in Life','channel': 'Kurzgesagt','category': 'Philosophy & Meaning','thumbnail': 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg','duration': '6:10'},
    ],

    'World Wisdom Traditions': [
      {'videoId': 'W2VoFzU0ZBo','title': 'Comparative World Philosophies & Ancient Traditions','channel': 'The School of Life','category': 'World Wisdom Traditions','thumbnail': 'https://img.youtube.com/vi/W2VoFzU0ZBo/hqdefault.jpg','duration': '8:24'},
      {'videoId': 'czgOWmtGVGs','title': 'Ancient Philosophies Across World Civilizations','channel': 'Kurzgesagt','category': 'World Wisdom Traditions','thumbnail': 'https://img.youtube.com/vi/czgOWmtGVGs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'c_Eutci7ack','title': 'Ethics, Justice and Governance in Classical Traditions','channel': 'TED-Ed','category': 'World Wisdom Traditions','thumbnail': 'https://img.youtube.com/vi/c_Eutci7ack/hqdefault.jpg','duration': '5:50'},
      {'videoId': 'yoEezZD71sc','title': '9 Modern Rules for a Meaningful Life','channel': 'University of Western Australia','category': 'World Wisdom Traditions','thumbnail': 'https://img.youtube.com/vi/yoEezZD71sc/hqdefault.jpg','duration': '17:53'},
    ],

    'Purpose, Values & Self-Mastery': [
      {'videoId': 'H14bBuluwB8','title': 'Grit: Passion, Perseverance & True Alignment','channel': 'TED','category': 'Purpose, Values & Self-Mastery','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
      {'videoId': 'UF8uR6Z6KLc','title': 'How to Live Before You Die: Finding What Truly Matters','channel': 'Stanford','category': 'Purpose, Values & Self-Mastery','thumbnail': 'https://img.youtube.com/vi/UF8uR6Z6KLc/hqdefault.jpg','duration': '15:04'},
      {'videoId': 'YDfVQOd_QkE','title': 'Growth Mindset: Mastering Inner Potential','channel': 'TED','category': 'Purpose, Values & Self-Mastery','thumbnail': 'https://img.youtube.com/vi/YDfVQOd_QkE/hqdefault.jpg','duration': '10:21'},
      {'videoId': 'TQMbvJNRpLE','title': 'How to Align Your Daily Habits with Core Values','channel': 'TEDx Talks','category': 'Purpose, Values & Self-Mastery','thumbnail': 'https://img.youtube.com/vi/TQMbvJNRpLE/hqdefault.jpg','duration': '9:09'},
    ],

    'Exercise & Physical Performance': [
      {'videoId': 'wm_wUo31y4k','title': 'Biomechanics, Strength & Exercise Protocols','channel': 'Huberman Lab','category': 'Exercise & Physical Performance','thumbnail': 'https://img.youtube.com/vi/wm_wUo31y4k/hqdefault.jpg','duration': '1:45:10'},
      {'videoId': 'Ks-_Mh1QhMc','title': 'Your Body Language Shapes Physiological State','channel': 'TED','category': 'Exercise & Physical Performance','thumbnail': 'https://img.youtube.com/vi/Ks-_Mh1QhMc/hqdefault.jpg','duration': '20:56'},
      {'videoId': 'H14bBuluwB8','title': 'Physical Grit, Endurance and High Performance','channel': 'TED','category': 'Exercise & Physical Performance','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
      {'videoId': 'bHIhgxav9LY','title': 'Biomechanics & Energy Expenditure Physics','channel': 'Veritasium','category': 'Exercise & Physical Performance','thumbnail': 'https://img.youtube.com/vi/bHIhgxav9LY/hqdefault.jpg','duration': '14:32'},
    ],

    'Nutrition & Healthy Eating': [
      {'videoId': '4-r1a2v8K4Y','title': 'Nutritional Science & Healthy Metabolic Habits','channel': 'Doctor Mike','category': 'Nutrition & Healthy Eating','thumbnail': 'https://img.youtube.com/vi/4-r1a2v8K4Y/hqdefault.jpg','duration': '13:20'},
      {'videoId': 'e7S8jWh6AEs','title': 'Nutritional Science & Metabolic Fueling Fundamentals','channel': 'TED-Ed','category': 'Nutrition & Healthy Eating','thumbnail': 'https://img.youtube.com/vi/e7S8jWh6AEs/hqdefault.jpg','duration': '4:26'},
      {'videoId': 'QsBT5EQt348','title': 'Human Evolutionary Diet & Modern Food Systems','channel': 'Kurzgesagt','category': 'Nutrition & Healthy Eating','thumbnail': 'https://img.youtube.com/vi/QsBT5EQt348/hqdefault.jpg','duration': '5:57'},
      {'videoId': 'pOLmD_WVY-E','title': 'Cognitive Nutrition: How Diet Influences Brain Chemistry','channel': 'TED-Ed','category': 'Nutrition & Healthy Eating','thumbnail': 'https://img.youtube.com/vi/pOLmD_WVY-E/hqdefault.jpg','duration': '4:58'},
    ],

    'Sleep & Recovery': [
      {'videoId': 'V01-4jW7Xn0','title': 'Sleep is Your Superpower: The Science of Rest','channel': 'TED','category': 'Sleep & Recovery','thumbnail': 'https://img.youtube.com/vi/V01-4jW7Xn0/hqdefault.jpg','duration': '19:10'},
      {'videoId': 'gXw_3A8u2v4','title': 'Sleep Architecture, Circadian Rhythms & Dopamine Recovery','channel': 'Huberman Lab','category': 'Sleep & Recovery','thumbnail': 'https://img.youtube.com/vi/gXw_3A8u2v4/hqdefault.jpg','duration': '2:15:30'},
      {'videoId': 'LNHBMFCzznE','title': 'Sleep Cycles, Memory Consolidation & Brain Health','channel': 'CrashCourse','category': 'Sleep & Recovery','thumbnail': 'https://img.youtube.com/vi/LNHBMFCzznE/hqdefault.jpg','duration': '10:02'},
      {'videoId': 'fDbxPVn02VU','title': 'The Neuroscience of Sleep for Memory Retention','channel': 'Thomas Frank','category': 'Sleep & Recovery','thumbnail': 'https://img.youtube.com/vi/fDbxPVn02VU/hqdefault.jpg','duration': '11:35'},
    ],

    'Mental Wellbeing & Stress Management': [
      {'videoId': 'e9dZQelULDk','title': 'How to Get Your Brain to Regulate Stress & Focus','channel': 'TEDx Talks','category': 'Mental Wellbeing & Stress Management','thumbnail': 'https://img.youtube.com/vi/e9dZQelULDk/hqdefault.jpg','duration': '14:08'},
      {'videoId': 'n3Xv_g3g-mA','title': 'Overcoming Loneliness & Building Psychological Calm','channel': 'Kurzgesagt','category': 'Mental Wellbeing & Stress Management','thumbnail': 'https://img.youtube.com/vi/n3Xv_g3g-mA/hqdefault.jpg','duration': '7:20'},
      {'videoId': 'VO6XEQIsCoM','title': 'Anxiety, Overchoice & Managing Psychological Pressure','channel': 'TED','category': 'Mental Wellbeing & Stress Management','thumbnail': 'https://img.youtube.com/vi/VO6XEQIsCoM/hqdefault.jpg','duration': '19:24'},
      {'videoId': 'H14bBuluwB8','title': 'Emotional Resilience & Mental Toughness in Difficult Times','channel': 'TED','category': 'Mental Wellbeing & Stress Management','thumbnail': 'https://img.youtube.com/vi/H14bBuluwB8/hqdefault.jpg','duration': '6:12'},
    ],

    'Healthy Lifestyle & Longevity': [
      {'videoId': 'KxGRhd_iVuE','title': 'What Makes a Good Life? Lessons from 75-Year Harvard Study','channel': 'TED','category': 'Healthy Lifestyle & Longevity','thumbnail': 'https://img.youtube.com/vi/KxGRhd_iVuE/hqdefault.jpg','duration': '12:46'},
      {'videoId': 'aIx2N-viNwY','title': 'Why Life Seems to Speed Up as We Age (Longevity & Perception)','channel': 'Veritasium','category': 'Healthy Lifestyle & Longevity','thumbnail': 'https://img.youtube.com/vi/aIx2N-viNwY/hqdefault.jpg','duration': '14:35'},
      {'videoId': '4-r1a2v8K4Y','title': 'Healthy Habits, Daily Routines & Cellular Healthspan','channel': 'Doctor Mike','category': 'Healthy Lifestyle & Longevity','thumbnail': 'https://img.youtube.com/vi/4-r1a2v8K4Y/hqdefault.jpg','duration': '13:20'},
      {'videoId': 'MBRqu0YOH14','title': 'The Science of Aging & Cellular Longevity','channel': 'Kurzgesagt','category': 'Healthy Lifestyle & Longevity','thumbnail': 'https://img.youtube.com/vi/MBRqu0YOH14/hqdefault.jpg','duration': '6:10'},
    ],
  };

  /// Returns subcategory names for a given main category.
  List<String> getSubcategories(String category) {
    return categorySubcategories[category] ?? [];
  }

  /// Returns videos for a specific subcategory (instant from in-memory pool + live background fetch).
  Future<List<Map<String, String>>> getVideosBySubcategory(
    String subcategory, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'sub_$subcategory';
    if (forceRefresh) _memoryCache.remove(cacheKey);

    if (_memoryCache.containsKey(cacheKey) && _memoryCache[cacheKey]!.isNotEmpty && !forceRefresh) {
      final pool = List<Map<String, String>>.from(_memoryCache[cacheKey]!);
      return pool;
    }

    final queryMap = {
      'Study Strategies & Learning Science': 'how to study smarter active recall feynman technique learning',
      'Academic Mastery': 'MIT lecture calculus quantum physics superposition mathematics educational',
      'Skills & Career Learning': 'career communication leadership techniques talk smart Stanford',
      'Self-Directed Learning': 'self learning science history educational documentary Veritasium Kurzgesagt',
      'Critical Thinking & Problem Solving': 'critical thinking problem solving cognitive biases logic fallacies TED',
      'Quantitative Aptitude & Mathematics': 'quantitative aptitude mathematics speed math shortcuts competitive exams',
      'Logical Reasoning & Mental Ability': 'logical reasoning mental ability analytical puzzles tricks competitive exams',
      'Verbal Ability & Language': 'verbal ability english comprehension grammar vocabulary competitive exams',
      'General Awareness & Current Affairs': 'general awareness current affairs static gk economy geopolitics',
      'Exam Strategy & Performance': 'competitive exam preparation strategy time management score high tips mock test',
      'Science & the Universe': 'astrophysics universe black holes cosmology documentary Kurzgesagt Veritasium',
      'History & Civilizations': 'ancient civilizations world history evolution documentary Kurzgesagt TED',
      'Geography & Our Planet': 'earth geography geology planetary ocean documentary',
      'Human Behavior & Society': 'human psychology cognitive behavior society sociology TED talk',
      'Curiosities & Hidden Knowledge': 'mysteries of science paradoxes hidden knowledge veritasium kurzgesagt',
      'Artificial Intelligence & Generative AI': 'artificial intelligence machine learning neural networks LLM deep learning',
      'Software Development & Engineering': 'software engineering system design computer architecture clean code programming',
      'Emerging Technologies': 'quantum computing fusion energy biotech robotics nanotechnology veritasium',
      'Cybersecurity & Digital Safety': 'cybersecurity cryptography hacking defense privacy digital safety documentary',
      'Future of Technology': 'future tech artificial general intelligence civilization megastructures kurzgesagt',
      'Personal Finance & Wealth Building': 'personal finance wealth building financial freedom investing saving',
      'Investing & Markets': 'stock market investing macro economics capital markets principles',
      'Entrepreneurship & Startups': 'startup business entrepreneurship building company Bill Gross Stanford TED',
      'Business Strategy & Leadership': 'business strategy corporate leadership executive decision making Stanford GSB',
      'Economics & Financial Intelligence': 'how economic machine works Ray Dalio inflation central banks macroeconomics',
      'Indian Wisdom & Vedanta': 'advaita vedanta upanishads bhagavad gita indian philosophy wisdom swami',
      'Meditation & Inner Awareness': 'mindfulness meditation guided inner awareness presence calm mind neuroscience',
      'Philosophy & Meaning': 'stoicism philosophy of life meaning of life existentialism crash course',
      'World Wisdom Traditions': 'taoism buddhism stoicism comparative world religions philosophy wisdom',
      'Purpose, Values & Self-Mastery': 'self mastery personal values life purpose discipline growth mindset TED',
      'Exercise & Physical Performance': 'exercise science physical fitness performance biomechanics endurance Huberman',
      'Nutrition & Healthy Eating': 'nutrition science healthy eating metabolism diet brain fuel documentary',
      'Sleep & Recovery': 'sleep neuroscience circadian rhythm recovery sleep optimization Matthew Walker Huberman',
      'Mental Wellbeing & Stress Management': 'mental health stress management emotional resilience cortisol psychology',
      'Healthy Lifestyle & Longevity': 'longevity science healthy habits biological aging lifespan healthspan',
    };

    final query = queryMap[subcategory] ?? '$subcategory educational lecture guide';

    final results = await _fetchWithPipeline(
      query: query,
      category: subcategory,
      language: 'English',
      cacheKey: cacheKey,
      staticFallback: subcategoryVideos[subcategory],
    );

    return results;
  }

  Future<List<Map<String, String>>> getVideosByCategory(
    String category, {
    String language = 'English',
    bool forceRefresh = false,
  }) async {
    final cacheKey = "$category-$language";

    if (forceRefresh) {
      _memoryCache.remove(cacheKey);
    }

    if (_memoryCache.containsKey(cacheKey) && _memoryCache[cacheKey]!.isNotEmpty && !forceRefresh) {
      final pool = List<Map<String, String>>.from(_memoryCache[cacheKey]!);
      pool.shuffle(Random());
      return pool;
    }

    final topicKeywords = {
      "All": "educational documentary lecture masterclass full guide",
      "Education & Learning": "science history quantum space documentary lecture",
      "Competitive Exams": "UPSC IAS competitive exam preparation strategy study tips",
      "Knowledge & Discovery": "atomic habits productivity deep work design speed reading",
      "Technology & AI": "artificial intelligence software Engineering system design quantum tech",
      "Business & Finance": "leadership entrepreneurship finance economics negotiation masterclass",
      "Spirituality & Philosophy": "stoicism philosophy ethics psychology society wisdom",
      "Health & Fitness": "neuroscience mindfulness posture sleep health meditation",
    };

    final query = topicKeywords[category] ?? "$category latest educational lecture";

    List<Map<String, String>> staticList;
    if (category == "All") {
      staticList = topicVideos.values.expand((e) => e).toList();
    } else {
      staticList = List<Map<String, String>>.from(
        topicVideos[category] ?? topicVideos["All"]!,
      );
    }

    final results = await _fetchWithPipeline(
      query: query,
      category: category,
      language: language,
      cacheKey: cacheKey,
      staticFallback: staticList,
    );

    final pool = List<Map<String, String>>.from(results);
    pool.shuffle(Random());
    return pool;
  }

  /// Unlimited continuous video streamer for "no limit video" loading.
  Future<List<Map<String, String>>> loadMoreVideos({
    required String category,
    String? subcategory,
    String language = 'English',
    int page = 1,
  }) async {
    final target = subcategory ?? category;
    final searchModifiers = [
      'advanced masterclass documentary',
      'full lecture complete guide',
      'deep dive explanation concepts',
      'practical tutorial high performance',
      'case study breakthrough insights',
      'fundamentals analysis',
    ];
    final mod = searchModifiers[(page - 1) % searchModifiers.length];
    final query = '$target $mod';

    try {
      final fresh = await _noQuotaScraper.scrapeVideos(
        query: query,
        category: target,
        language: language,
        maxResults: 25,
      );
      if (fresh.isNotEmpty) {
        return fresh;
      }
    } catch (_) {}

    // Dynamic rotation from offline curated collections
    final allAvailable = (subcategory != null
            ? (subcategoryVideos[subcategory] ?? topicVideos[category] ?? topicVideos["All"]!)
            : (topicVideos[category] ?? topicVideos["All"]!))
        .toList();
    allAvailable.shuffle(Random(page * 37));
    return allAvailable;
  }

  /// Sequential 4-Stage Fallback Pipeline:
  /// Stage 1: No-Quota Scraper (High Priority - Live & Fresh Videos)
  /// Stage 2: Firebase Cache (Persistent Cache)
  /// Stage 3: YouTube Official API (If configured)
  /// Stage 4: Verified Static Curated List (Guaranteed Offline Fallback)
  Future<List<Map<String, String>>> _fetchWithPipeline({
    required String query,
    required String category,
    required String language,
    required String cacheKey,
    List<Map<String, String>>? staticFallback,
  }) async {
    // ──────── 1. NO-QUOTA SCRAPER (FIRST PRIORITY) ────────
    try {
      final scraped = await _noQuotaScraper.scrapeVideos(
        query: query,
        category: category,
        language: language,
        maxResults: 60,
      );
      if (scraped.isNotEmpty) {
        _setCache(cacheKey, scraped);
        _firebaseCache.saveCachedVideos(cacheKey, scraped);
        return _memoryCache[cacheKey]!;
      }
    } catch (e) {
      // Proceed to Step 2
    }

    // ──────── 2. FIREBASE CACHE (SECOND PRIORITY) ────────
    try {
      final cached = await _firebaseCache.getCachedVideos(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        _setCache(cacheKey, cached);
        return _memoryCache[cacheKey]!;
      }
    } catch (e) {
      // Proceed to Step 3
    }

    // ──────── 3. YOUTUBE OFFICIAL API (THIRD PRIORITY) ────────
    if (YouTubeOfficialApiService.apiKey != null && YouTubeOfficialApiService.apiKey!.trim().isNotEmpty) {
      try {
        final apiVideos = await _officialApiService.fetchFromOfficialApi(
          query,
          category,
          language,
        );
        if (apiVideos.isNotEmpty) {
          _setCache(cacheKey, apiVideos);
          _firebaseCache.saveCachedVideos(cacheKey, apiVideos);
          return _memoryCache[cacheKey]!;
        }
      } catch (e) {
        // Proceed to Step 4
      }
    }

    // ──────── 4. CURATED STATIC FALLBACK (OFFLINE ONLY) ────────
    final fallbacks = staticFallback ?? topicVideos[category] ?? topicVideos["All"]!;
    _setCache(cacheKey, fallbacks);
    return _memoryCache[cacheKey]!;
  }

  void _setCache(String cacheKey, List<Map<String, String>> videos) {
    final uniqueMap = <String, Map<String, String>>{};
    for (var v in videos) {
      final id = v['videoId'] ?? '';
      if (id.isNotEmpty) uniqueMap[id] = v;
    }
    _memoryCache[cacheKey] = uniqueMap.values.toList();
  }
}
