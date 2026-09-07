import 'package:coairence/data/models/breath_step.dart';
import 'package:coairence/data/models/breathing_pattern.dart';
import 'package:coairence/data/models/pattern_tag.dart';
import 'package:coairence/data/models/source.dart';
import 'package:material_ui/material_ui.dart';

class BreatheRepository {
  final List<BreathingPattern> _patterns = [
    // ─── CALMING & ANXIETY RELIEF ────────────────────────────────────────
    BreathingPattern(
      id: 'box_breathing',
      name: 'Box Breathing',
      shortDescription:
          'Used by Navy SEALs. Equal counts of inhale, hold, exhale, and hold.',
      detailedDescription: 'Box Breathing, also known as Square Breathing or Tactical Breathing, uses four equal phases to create a controlled, rhythmic breathing pattern. Originally popularized by military special forces for high-stress situations, it has since been studied as a tool for autonomic regulation. The equal-phase structure provides a cognitive anchor that distracts from anxious thoughts while shifting the body toward parasympathetic dominance.',
      mechanism: 'Equal-duration phases with extended exhalation suppress sympathetic drive and enhance parasympathetic tone, increasing Heart Rate Variability (HRV).',
      scientificBasis: 'Slow-breathing techniques below 10 breaths/minute are associated with increased Heart Rate Variability and Respiratory Sinus Arrhythmia, alongside reduced markers of arousal and anxiety, per a 2018 systematic review of 15 studies meeting PRISMA eligibility criteria.',
      sources: [
        const Source(
          title: 'How Breath-Control Can Change Your Life: A Systematic Review on Psycho-Physiological Correlates of Slow Breathing',
          url: 'https://doi.org/10.3389/fnhum.2018.00353',
          author: 'Zaccaro, A., Piarulli, A., Laurino, M., et al.',
          publication: 'Frontiers in Human Neuroscience, 12:353 (2018)',
        ),
      ],
      tags: [PatternTag.calming, PatternTag.focus],
      icon: Icons.crop_square,
      accentColor: Colors.indigo,
      benefits: [
        'Increases Heart Rate Variability (HRV)',
        'Prevents stress-induced heart rate spikes',
        'Provides a cognitive anchor during anxiety',
        'Improves attention and emotional regulation',
      ],
      contraindications: [
        'Holding the breath may be uncomfortable for those with respiratory conditions; reduce hold duration if needed.',
      ],
      tips: [
        'Visualize tracing the four sides of a square as you breathe through each phase.',
        'Keep the transitions between phases smooth, not abrupt.',
        'Start with 4-second phases; increase to 5 or 6 seconds as comfort allows.',
      ],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 4)),
      ],
    ),

    BreathingPattern(
      id: 'triangle_breathing',
      name: 'Triangle Breathing',
      shortDescription:
          'A gentler alternative to Box Breathing without the empty-lung hold.',
      detailedDescription: 'Triangle Breathing removes the post-exhalation hold found in Box Breathing, creating a continuous three-phase cycle of inhale, hold, and exhale. This makes it more accessible for people who find holding their breath on empty lungs uncomfortable, while retaining the calming effect of extended exhalation in an uninterrupted flow.',
      mechanism: 'Continuous flow with extended exhalation supports parasympathetic activation without the potential discomfort of empty-lung retention.',
      scientificBasis: 'Extended-exhalation slow breathing is linked in the literature to increased vagal tone and reduced sympathetic arousal, consistent with the broader evidence base for slow-breathing techniques.',
      sources: [
        const Source(
          title: 'How Breath-Control Can Change Your Life: A Systematic Review on Psycho-Physiological Correlates of Slow Breathing',
          url: 'https://doi.org/10.3389/fnhum.2018.00353',
          author: 'Zaccaro, A., Piarulli, A., Laurino, M., et al.',
          publication: 'Frontiers in Human Neuroscience, 12:353 (2018)',
        ),
      ],
      tags: [PatternTag.calming],
      icon: Icons.change_history,
      accentColor: Colors.blueGrey,
      benefits: [
        'Gentler than Box Breathing for breath-hold sensitive users',
        'Supports parasympathetic activation',
        'Continuous rhythm reduces cognitive load',
        'Effective for sustained anxiety management',
      ],
      contraindications: [],
      tips: [
        'Think of the breath as a triangle: up (inhale), across (hold), down (exhale).',
        'If the hold feels too long, shorten it to 2–3 seconds.',
        'Focus on making the exhale longer than the inhale for maximum calming effect.',
      ],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 4)),
      ],
    ),

    BreathingPattern(
      id: 'relaxing_breath_478',
      name: '4-7-8 Relaxing Breath',
      shortDescription: 'A natural tranquilizer with extended hold and exhale for deep relaxation.',
      detailedDescription: 'Popularized by Dr. Andrew Weil, the 4-7-8 technique uses a prolonged post-inhalation hold and an even longer exhalation to create a sedative effect. At roughly 3.2 breaths per minute (4+7+8=19s per cycle), it is notably slower than resonant-frequency pacing, making it better suited to deep relaxation and sleep initiation than to HRV biofeedback training.',
      mechanism: 'A long exhalation and post-inhalation hold support parasympathetic activation via vagal stimulation.',
      scientificBasis: 'Extended-exhalation breathing ratios are commonly recommended by clinical sources for calming the nervous system and easing sleep onset.',
      sources: [
        const Source(
          title: 'Breathing Exercises for Stress and Anxiety Management',
          url: 'https://www.health.harvard.edu/mind-and-mood/breathing-exercises-for-stress-and-anxiety-management',
          author: 'Harvard Health Publishing',
          publication: 'Harvard Medical School',
        ),
      ],
      tags: [PatternTag.calming, PatternTag.sleep],
      icon: Icons.cloud,
      accentColor: Colors.lightBlue,
      recommendedDuration: const Duration(minutes: 4),
      benefits: [
        'Acts as a natural tranquilizer for the nervous system',
        'Facilitates sleep onset',
        'Quiets racing thoughts through focused counting',
      ],
      contraindications: [
        'The 7-second hold may cause air hunger in beginners; reduce to 4–5 seconds initially.',
        'Not ideal for HRV training due to the sub-resonant breathing rate.',
      ],
      tips: [
        'Place the tip of your tongue against the ridge behind your upper front teeth throughout.',
        'Exhale through your mouth with a gentle "whoosh" sound.',
        'Limit to 4 cycles when first starting; gradually increase to 8.',
      ],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 7)),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 8),
          mode: BreathMode.mouth, // required: drives the mouth-exhale audio cue
        ),
      ],
    ),

    // ─── SLEEP & DEEP RELAXATION ─────────────────────────────────────────
    BreathingPattern(
      id: 'deep_sleep_1_2',
      name: 'Deep Sleep (1:2 Ratio)',
      shortDescription: 'Prolonged exhale significantly slows heart rate to prepare for sleep.',
      detailedDescription: 'The 1:2 ratio breathing pattern doubles exhalation relative to inhalation, giving a simple, easy-to-sustain signal for sleep preparation — useful in bed when cognitive resources are low. Extended-exhalation slow breathing is part of the same evidence base underpinning most calming and sleep-oriented techniques in this app.',
      mechanism: 'Doubling exhalation duration supports vagal activity, slowing heart rate and favoring rest-and-digest physiology.',
      scientificBasis: 'Consistent with the broader slow-breathing literature linking extended exhalation to increased parasympathetic tone.',
      sources: [
        const Source(
          title: 'How Breath-Control Can Change Your Life: A Systematic Review on Psycho-Physiological Correlates of Slow Breathing',
          url: 'https://doi.org/10.3389/fnhum.2018.00353',
          author: 'Zaccaro, A., Piarulli, A., Laurino, M., et al.',
          publication: 'Frontiers in Human Neuroscience, 12:353 (2018)',
        ),
      ],
      tags: [PatternTag.sleep, PatternTag.calming],
      icon: Icons.nightlight_round,
      accentColor: Colors.deepPurple,
      recommendedDuration: const Duration(minutes: 10),
      benefits: [
        'Directly prepares the body for sleep onset',
        'Simple ratio, easy to maintain when fatigued',
      ],
      contraindications: [],
      tips: [
        'Practice lying down in your sleep position.',
        'Let the inhale be passive and effortless; only actively extend the exhale.',
        'If 4:8 feels too long, start with 3:6 and build up.',
      ],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 4)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 8)),
      ],
    ),

    BreathingPattern(
      id: 'yoga_nidra',
      name: 'Yoga Nidra Foundation',
      shortDescription: 'Guided conscious relaxation inducing a state between waking and sleeping.',
      detailedDescription: 'Yoga Nidra ("yogic sleep") is a systematic relaxation practice that guides awareness through body scanning, breath observation, and visualization toward the hypnagogic state between wakefulness and sleep. This pattern represents only the underlying breath rhythm; the full practice is normally guided verbally.',
      mechanism: 'Slow, effortless breathing paired with progressive relaxation supports parasympathetic dominance while maintaining conscious awareness.',
      scientificBasis: 'A 2025 randomised controlled trial found that daily practice of a short (11-minute) Yoga Nidra recording produced measurable improvements in stress, sleep, and well-being outcomes compared to a waitlist control, along with changes in diurnal cortisol patterns.',
      sources: [
        const Source(
          title: 'The Effects of an Online Yoga Nidra Meditation on Subjective Well-Being and Diurnal Salivary Cortisol: A Randomised Controlled Trial',
          url: 'https://doi.org/10.1002/smi.70049',
          author: 'Moszeik, E. N., Rohleder, N., & Renner, K.-H.',
          publication: 'Stress and Health, 41(3):e70049 (2025)',
        ),
      ],
      tags: [PatternTag.sleep, PatternTag.calming, PatternTag.pranayama],
      icon: Icons.self_improvement,
      accentColor: Colors.purple,
      recommendedDuration: const Duration(minutes: 20),
      benefits: [
        'Supports physical and mental relaxation',
        'Associated with improved stress, sleep, and well-being measures with regular practice',
      ],
      contraindications: [
        'May surface suppressed emotions; practice in a safe environment.',
        'Those with severe trauma should practice under guidance of a trained facilitator.',
      ],
      tips: [
        'Lie flat on your back in Savasana position with palms facing up.',
        'Use a blanket; body temperature drops during deep relaxation.',
        'This pattern represents the foundational breath rhythm; pair with guided audio for full effect.',
      ],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 5)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 5)),
      ],
    ),

    // ─── HRV OPTIMIZATION ────────────────────────────────────────────────
    BreathingPattern(
      id: 'coherent_breathing',
      name: 'Coherent Breathing',
      shortDescription:
          'The gold standard for maximizing Heart Rate Variability (HRV).',
      detailedDescription: 'Coherent Breathing, also known as Resonant Frequency Breathing, paces respiration at roughly 5 breaths per minute (6-second inhale, 6-second exhale). This rhythm synchronizes heart rate, blood pressure, and respiration into a coherent sine-wave pattern that maximizes HRV amplitude, and underpins clinical HRV biofeedback protocols.',
      mechanism: 'Pacing breath near 5 breaths per minute entrains cardiovascular and respiratory oscillators toward resonance, maximizing HRV amplitude.',
      scientificBasis: 'HRV biofeedback research attributes its effects primarily to strengthened baroreceptor homeostasis, with resonance-frequency breathing producing the largest heart-rate oscillations.',
      sources: [
        const Source(
          title:
              'Heart Rate Variability Biofeedback: How and Why Does It Work?',
          url: 'https://doi.org/10.3389/fpsyg.2014.00756',
          author: 'Lehrer, P. M., & Gevirtz, R.',
          publication: 'Frontiers in Psychology, 5:756 (2014)',
        ),
      ],
      tags: [PatternTag.hrv, PatternTag.calming, PatternTag.focus],
      icon: Icons.favorite_border,
      accentColor: Colors.teal,
      recommendedDuration: const Duration(minutes: 10),
      benefits: [
        'Maximizes Heart Rate Variability (HRV) amplitude',
        'Supports autonomic nervous system balance',
        'Used as the core protocol in clinical HRV biofeedback training',
      ],
      contraindications: [
        'May cause mild lightheadedness initially; reduce duration if this occurs.',
      ],
      tips: [
        'Breathe gently and smoothly; never force the air.',
        'Keep shoulders relaxed; breathe primarily into the lower belly.',
        'Aim for seamless transitions between inhale and exhale with no pauses.',
      ],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 6)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 6)),
      ],
    ),

    // ─── ACUTE STRESS INTERVENTION ───────────────────────────────────────
    BreathingPattern(
      id: 'physiological_sigh',
      name: 'Physiological Sigh',
      shortDescription: 'Double-inhale pops open alveoli; long exhale offloads CO₂ instantly.',
      detailedDescription: 'The Physiological Sigh is a naturally occurring pattern the body uses to reinflate collapsed alveoli, most often observed during sleep. Consciously applied, a double inhale followed by a long exhale is one of the fastest voluntary methods to reduce acute physiological arousal.',
      mechanism: 'A double inhale reinflates collapsed alveoli for improved gas exchange; the following long exhale offloads CO₂, supporting a rapid downshift in physiological arousal.',
      scientificBasis: 'A remote randomized controlled trial comparing daily 5-minute breathwork exercises to mindfulness meditation found that cyclic sighing, with its emphasis on prolonged exhalation, produced the greatest improvement in mood and reduction in respiratory rate among the tested conditions.',
      sources: [
        const Source(
          title: 'Brief Structured Respiration Practices Enhance Mood and Reduce Physiological Arousal',
          url: 'https://doi.org/10.1016/j.xcrm.2022.100895',
          author: 'Balban, M. Y., Neri, E., Kogon, M. M., Weed, L., Nouriani, B., Jo, B., Holl, G., Zeitzer, J. M., Spiegel, D., & Huberman, A. D.',
          publication: 'Cell Reports Medicine, 4(1):100895 (2023)',
        ),
      ],
      tags: [PatternTag.acute, PatternTag.calming],
      icon: Icons.bolt,
      accentColor: Colors.orange,
      recommendedDuration: const Duration(minutes: 1),
      benefits: [
        'Rapid method to reduce acute stress',
        'Lowers respiratory rate and improves mood after brief daily practice',
        'Reinflates collapsed alveoli for improved oxygen exchange',
      ],
      contraindications: [
        'Not intended for continuous long-duration practice.',
        'Stop immediately if dizzy or lightheaded.',
      ],
      tips: [
        'The second inhale is a short, sharp "sip" through the nose to fully expand lungs.',
        'Exhale slowly and completely through pursed lips or open mouth.',
        'Repeat only 1–3 cycles per reset; use as an on-demand tool, not a daily training protocol.',
      ],
      steps: [
        BreathStep(breathTo: 0.5, duration: const Duration(seconds: 2)),
        BreathStep(breathTo: 1, duration: const Duration(seconds: 1)),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 6),
          mode: BreathMode.mouth,
        ),
      ],
    ),

    // ─── ENERGY & FOCUS ──────────────────────────────────────────────────
    BreathingPattern(
      id: 'energizing_power_breath',
      name: 'Energizing Power Breath',
      shortDescription:
          'Fast, rhythmic breathing increases oxygenation and alertness.',
      detailedDescription: 'Energizing Power Breath uses rapid, rhythmic nasal breathing to intentionally activate the sympathetic nervous system — a caffeine-free method to increase alertness and counter fatigue, similar in spirit to traditional fast pranayama practices.',
      mechanism: 'Rapid rhythmic breathing increases sympathetic drive and oxygen turnover, producing an energizing physiological state.',
      scientificBasis: 'A randomized study comparing 12 weeks of fast pranayama (kapalabhati, bhastrika, kukkuriya) against slow pranayama in healthy volunteers found both improved executive function and reaction time, with fast pranayama producing a significantly larger reduction in reaction time.',
      sources: [
        const Source(
          title: 'Effect of Fast and Slow Pranayama Practice on Cognitive Functions in Healthy Volunteers',
          url: 'https://doi.org/10.7860/JCDR/2014/7256.3668',
          author: 'Sharma, V. K., Rajajeyakumar, M., Velkumary, S., Subramanian, S. K., Bhavanani, A. B., Madanmohan, Sahai, A., & Thangavel, D.',
          publication:
              'Journal of Clinical and Diagnostic Research, 8(1):10-13 (2014)',
        ),
      ],
      tags: [PatternTag.energy, PatternTag.focus],
      icon: Icons.flash_on,
      accentColor: Colors.amber,
      recommendedDuration: const Duration(minutes: 2),
      benefits: [
        'Associated with improved reaction time and executive function',
        'Boosts oxygenation without stimulants',
        'Counters fatigue and afternoon slump',
      ],
      contraindications: [
        'Not recommended for those with hypertension, heart conditions, or anxiety disorders.',
        'Stop if dizzy, lightheaded, or experiencing chest discomfort.',
      ],
      tips: [
        'Keep the breath rhythmic and even; avoid straining.',
        'Breathe through the nose throughout.',
        'Follow with 1–2 minutes of normal breathing to stabilize.',
      ],
      steps: [
        BreathStep(breathTo: 1, duration: const Duration(seconds: 2)),
        BreathStep(breathTo: 0, duration: const Duration(seconds: 2)),
      ],
    ),

    BreathingPattern(
      id: 'alternate_nostril_breathing',
      name: 'Alternate Nostril Breathing',
      shortDescription:
          'Yogic Nadi Shodhana balances brain hemispheres and calms the mind.',
      detailedDescription: 'Nadi Shodhana, or Alternate Nostril Breathing, alternates airflow between left and right nostrils. It is one of the most studied pranayama techniques and is used as both a calming and focusing practice.',
      mechanism: 'Alternating unilateral nasal breathing is theorized to stimulate contralateral brain hemispheres, potentially balancing autonomic tone.',
      scientificBasis: 'Studies on alternate nostril breathing report increased parasympathetic modulation of heart rate variability following practice compared to paced breathing at the same rate, along with improvements in verbal and spatial memory scores after short-term daily practice.',
      sources: [
        const Source(
          title: 'Influence of Alternate Nostril Breathing on Heart Rate Variability in Non-Practitioners of Yogic Breathing',
          url: 'https://doi.org/10.4103/0973-6131.91717',
          author: 'Ghiya, S., & Lee, C. M.',
          publication: 'International Journal of Yoga, 5(1):66-69 (2012)',
        ),
        const Source(
          title: 'Effect of Left, Right and Alternate Nostril Breathing on Verbal and Spatial Memory',
          url: 'https://doi.org/10.7860/JCDR/2016/12361.7197',
          author: 'Garg, R., Malhotra, V., Tripathi, Y., & Agarawal, R.',
          publication: 'Journal of Clinical and Diagnostic Research, 10(2):CC01-CC03 (2016)',
        ),
      ],
      tags: [PatternTag.focus, PatternTag.calming, PatternTag.pranayama],
      icon: Icons.swap_horiz,
      accentColor: Colors.green,
      benefits: [
        'Associated with increased parasympathetic HRV modulation after practice',
        'Linked to improved verbal and spatial memory scores',
        'Combines calming and focusing effects',
      ],
      contraindications: [
        'Avoid if nasal passages are completely blocked.',
        'Those with severe respiratory conditions should practice gently.',
      ],
      tips: [
        'Use Vishnu Mudra: fold index and middle fingers; use thumb for right nostril, ring finger for left.',
        'Always begin and end on the left nostril.',
        'Keep the breath silent, smooth, and unforced.',
      ],
      steps: [
        BreathStep(
          breathTo: 1,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseLeft,
        ),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseRight,
        ),
        BreathStep(
          breathTo: 1,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseRight,
        ),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseLeft,
        ),
      ],
    ),

    BreathingPattern(
      id: 'surya_bhedana',
      name: 'Surya Bhedana',
      shortDescription: 'Right-nostril breathing activates energy channels and increases alertness.',
      detailedDescription: 'Surya Bhedana, or Solar Breath, involves inhaling through the right nostril and exhaling through the left. In yogic tradition the right nostril is associated with the Pingala nadi and sympathetic activation. This is a targeted energizing practice, distinct from bilateral techniques like Nadi Shodhana.',
      mechanism: 'Unilateral right-nostril breathing is theorized to preferentially engage sympathetic activation.',
      scientificBasis: 'A month-long training study found that practicing exclusive right-nostril breathing (Surya Anuloma Viloma) increased baseline oxygen consumption by 37%, a larger increase than seen with alternate-nostril or left-nostril breathing, consistent with selective sympathetic activation.',
      sources: [
        const Source(
          title: 'Physiological Measures of Right Nostril Breathing (Surya Anuloma Viloma Pranayama)',
          url: 'https://www.ijpp.com/IJPP%20archives/1994_38_2/133-137.pdf',
          author: 'Telles, S., Nagarathna, R., & Nagendra, H. R.',
          publication: 'Indian Journal of Physiology and Pharmacology, 38(2):133-137 (1994)',
        ),
      ],
      tags: [PatternTag.energy, PatternTag.focus, PatternTag.pranayama],
      icon: Icons.wb_sunny,
      accentColor: Colors.deepOrange,
      recommendedDuration: const Duration(minutes: 3),
      benefits: [
        'Shown to increase baseline oxygen consumption (metabolic activation)',
        'Traditionally used to increase alertness and mental energy',
      ],
      contraindications: [
        'Avoid if you have hypertension, heart disease, or hyperthyroidism.',
        'Do not practice during fever or acute inflammation.',
        'Balance with left-nostril breathing (Chandra Bhedana) afterward to restore equilibrium.',
      ],
      tips: [
        'Close the left nostril with your ring finger; inhale slowly through the right.',
        'Switch to close the right nostril; exhale slowly through the left.',
        'Always follow with several minutes of normal bilateral breathing.',
      ],
      steps: [
        BreathStep(
          breathTo: 1,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseRight,
        ),
        BreathStep(
          breathTo: 0,
          duration: const Duration(seconds: 4),
          mode: BreathMode.noseLeft,
        ),
      ],
    ),

    BreathingPattern(
      id: 'bhastrika',
      name: 'Bhastrika (Bellows Breath)',
      shortDescription: 'Vigorous yogic bellows breath ignites internal heat and boosts metabolism.',
      detailedDescription: 'Bhastrika Pranayama, or Bellows Breath, is a vigorous classical pranayama technique with forceful, diaphragm-driven inhalations and exhalations at a rapid pace, traditionally used to generate internal heat (tapas). Both phases are active, unlike the passive-inhale Kapalabhati.',
      mechanism: 'Forceful diaphragmatic pumping increases sympathetic drive, cardiac output, and metabolic rate.',
      scientificBasis: 'A study comparing cardiovascular changes during four yogic breathing techniques found Bhastrika produced significant increases in heart rate, diastolic blood pressure, mean arterial pressure, and cardiac output during practice — supporting its traditional classification as a vigorous, stimulating pranayama and the contraindications below.',
      sources: [
        const Source(
          title: 'Evaluation of Cardiovascular Functions During the Practice of Different Types of Yogic Breathing Techniques',
          url: 'https://doi.org/10.4103/ijoy.ijoy_61_20',
          author: 'Nivethitha, L., Mooventhan, A., & Manjunath, N. K.',
          publication: 'International Journal of Yoga, 14(2):158-162 (2021)',
        ),
      ],
      tags: [PatternTag.energy, PatternTag.pranayama],
      icon: Icons.local_fire_department,
      accentColor: Colors.redAccent,
      recommendedDuration: const Duration(minutes: 3),
      benefits: [
        'Measurably increases heart rate, blood pressure, and cardiac output during practice',
        'Traditionally used to generate internal heat and increase alertness',
        'Clears nasal passages and strengthens respiratory muscles',
      ],
      contraindications: [
        'Strictly contraindicated for hypertension, heart disease, epilepsy, hernia, or glaucoma.',
        'Not recommended during pregnancy or menstruation.',
        'Stop immediately if dizzy, faint, or experiencing chest pain.',
        'Beginners should limit to 10–15 cycles and always rest afterward.',
      ],
      tips: [
        'Keep the spine erect; let the diaphragm drive the breath, not the chest or shoulders.',
        'Both inhalation and exhalation are active and forceful, unlike Kapalabhati.',
        "Always follow with 2–3 minutes of quiet normal breathing and observe your body's response.",
      ],
      steps: [
        BreathStep(
          breathTo: 1,
          duration: const Duration(milliseconds: 500),
        ),
        BreathStep(
          breathTo: 0,
          duration: const Duration(milliseconds: 500),
        ),
      ],
    ),
  ];

  List<BreathingPattern> get patterns => _patterns;

  List<PatternTag> get availableTags =>
      _patterns.expand((p) => p.tags).toSet().toList();

  /// Filter patterns by one or more tags
  List<BreathingPattern> getPatternsByTags(List<PatternTag> filterTags) {
    if (filterTags.isEmpty) return _patterns;
    return _patterns
        .where((p) => p.tags.any((t) => filterTags.contains(t)))
        .toList();
  }

  BreathingPattern? getPatternById(String id) =>
      _patterns.firstWhere((p) => p.id == id);
}
