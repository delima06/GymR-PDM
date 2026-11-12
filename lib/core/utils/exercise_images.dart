class ExerciseImageHelper {
  static const Map<String, String> _knownExerciseImages = {
    'supino reto com barra':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCjGtnFj5bhqSz6uy11ea79jhW3hfC_ettwmRI7M9xQ1i7G52mBNyUx_oFQDTcQhqnLp9sMwphXXToQ56nR8F4ob4A776KRq_TFYEywh0PdQrKQKlx6rerp7nNsqIQ62ogZr1xcpEBkykT6F6CXT6eugdK2QNLnoLiXyqCQyzTV3vANLss_2iRUEcrn-XJniUsx4eBbewduk_pKKBO9hEmbg8hVBLL1wK2bD7Mf2WkO',
    'supino inclinado c/ halteres':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBMIVAPxRDoWcYSAg7gpaAtmsIGPYEU2rsBogZEkPZeYTzcVTSfkHWzq_IwUw5Xehivtb5kCK0YkXA3oIm40NJquba-T3AYqu0Vs8hX7dEYCZ007mkmPkTq5mmXgyy2nqe-vfvyZzHQcHheNBynwTENTxcj6ExdBDDtNn7eLfpQQTU4RkzelxKd03QL0dwtNgi5EFNk9hqTVyJ5nwgMtXJabnrmJsQ3bFTu2ollI3pb',
    'supino inclinado com halteres':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBMIVAPxRDoWcYSAg7gpaAtmsIGPYEU2rsBogZEkPZeYTzcVTSfkHWzq_IwUw5Xehivtb5kCK0YkXA3oIm40NJquba-T3AYqu0Vs8hX7dEYCZ007mkmPkTq5mmXgyy2nqe-vfvyZzHQcHheNBynwTENTxcj6ExdBDDtNn7eLfpQQTU4RkzelxKd03QL0dwtNgi5EFNk9hqTVyJ5nwgMtXJabnrmJsQ3bFTu2ollI3pb',
    'desenvolvimento militar':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBnhHW9hanzpq25uIL97k1CSpHKlIoVWxXq4JUn8ASf9uVsy8b1C2M0JB8FnMIZu9f0GJ0ivJxKKE-eKeMuCgYTGkPwv74myb9RLoa9ybAqR511rrWS583n7WBt0IP_9hUxRmYrlwSplT9CdDTmQvqBSogsBnixJtLinsTCD0dXWT6vTvV_Sn9ROWCgxbNfoozPG4LbvSn2trFqfJkZGfsMY7PbVUAJDy7DM4yiTyFO',
    'elevação lateral na polia':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDwyo7CnfgpOSnczE2CzKC8sZYRRm5hvVloHz4Je6K0GWmQGnVsuOYrGxe3EqtU3f_OhCTSn1Om00cAw_KeyYWWmEbS4AO0XZSEZPFUOzl0VIEIQM7Fi-PjfTYNt-epAVMeYx4EAnWvVBs2yxTYZpT9JnnMigN6qPw_DOKHh8KcUtpFrUXUPGkGeToTsODM1roumepVzcbEhMvL4u9_Y6MHuXsonJeT2AYTqKaK9dv6',
    'elevação lateral':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDwyo7CnfgpOSnczE2CzKC8sZYRRm5hvVloHz4Je6K0GWmQGnVsuOYrGxe3EqtU3f_OhCTSn1Om00cAw_KeyYWWmEbS4AO0XZSEZPFUOzl0VIEIQM7Fi-PjfTYNt-epAVMeYx4EAnWvVBs2yxTYZpT9JnnMigN6qPw_DOKHh8KcUtpFrUXUPGkGeToTsODM1roumepVzcbEhMvL4u9_Y6MHuXsonJeT2AYTqKaK9dv6',
    'tríceps corda na polia':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB7eBy1KLco69cTjA0D8D8eJnpis6TmKGfsIIZCWtlHu2mKDY7vOWo2L4-V9gL6JURG9LAISaeAr-YaP3MrR4BPvRwKWg5k82rH_I-Bdod6qUaUnmKl5PHNxz8NmommNLibgkpaENL29VxV1umM2nazMy4-2HEdXIpKWQUehLmRNQm_EYZSjE2pBssVaYV7X3gmWDQyG2WW_GOg40io_C0vwLJYc-Ve2jV9OtV8D6O1',
    'tríceps corda':
        'https://lh3.googleusercontent.com/aida-public/AB6AXuB7eBy1KLco69cTjA0D8D8eJnpis6TmKGfsIIZCWtlHu2mKDY7vOWo2L4-V9gL6JURG9LAISaeAr-YaP3MrR4BPvRwKWg5k82rH_I-Bdod6qUaUnmKl5PHNxz8NmommNLibgkpaENL29VxV1umM2nazMy4-2HEdXIpKWQUehLmRNQm_EYZSjE2pBssVaYV7X3gmWDQyG2WW_GOg40io_C0vwLJYc-Ve2jV9OtV8D6O1',
    'puxada aberta na frente':
        'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?auto=format&fit=crop&w=400&q=80',
    'remada curvada com barra':
        'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=400&q=80',
    'agachamento livre com barra':
        'https://images.unsplash.com/photo-1574680096145-d05b474e2155?auto=format&fit=crop&w=400&q=80',
    'leg press 45°':
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=400&q=80',
  };

  static const String coachNarezUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';

  static const String todayWorkoutCoverUrl =
      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=400&q=80';

  static const String athleteAvatarUrl =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80';

  static String? getExerciseImageUrl(String exerciseName) {
    final lower = exerciseName.toLowerCase().trim();
    for (final entry in _knownExerciseImages.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }
    // Fallback genérico atlético
    return 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=300&q=80';
  }
}

