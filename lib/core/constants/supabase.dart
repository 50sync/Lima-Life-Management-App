import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
User? get user => supabase.auth.currentUser;
String? get userId => user?.id;
