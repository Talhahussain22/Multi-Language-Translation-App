import 'package:ai_text_to_speech/screen/FavouriteWordTestScreen.dart';
import 'package:ai_text_to_speech/screen/GeneralTestScreen.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  TestPage({super.key});
  
  int count=10;

  Widget _testCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.black12, width: 0.8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.18)),
                ),
                child: Icon(icon, color: const Color(0xFF1976D2), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.deepOrange.withOpacity(0.18)),
                          ),
                          child: const Text('Tap to start', style: TextStyle(color: Colors.deepOrange, fontSize: 11, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 51, 102, 1),
        title: Text(
          'Vocabulary Test',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/brain2.png',height: 150,)),
              Center(child: Text('Ready to challenge your brain?',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 0,color: Colors.grey.shade800),)),
              const SizedBox(height: 20),
              Text('Vocabulary Tests',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,letterSpacing: -0.5,color: Colors.grey.shade800),),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text('Practise your language skills with test based on your favourite words and general vocabulary.',style: TextStyle(letterSpacing: -0.5,color: Colors.grey.shade800),),
              ),
              const SizedBox(height: 20),
              Text('Available Tests',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,letterSpacing: 0,color: Colors.grey.shade800),),
              const SizedBox(height: 10),

              _testCard(
                context: context,
                icon: Icons.menu_book,
                title: 'Favourite Words',
                subtitle: 'Reflective Learning • Pick your number of questions',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FavouriteWordTestScreen()));
                },
              ),
              const SizedBox(height: 10),
              _testCard(
                context: context,
                icon: Icons.article,
                title: 'General Words',
                subtitle: 'Vocabulary Booster • Default 10 questions',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>GeneralTestScreen()));
                },
              ),

              const SizedBox(height: 18),
              Row(
                children: const [
                  Icon(Icons.info_outline, size: 18, color: Colors.black45),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'An ad may appear after you finish a test. We never show ads before starting.',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
