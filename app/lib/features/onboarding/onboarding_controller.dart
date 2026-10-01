import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models.dart';

class OnboardingState {
  const OnboardingState({this.interests = const {}, this.destinations = const {}, this.voice = const []});

  final Set<Interest> interests;
  final Set<Destination> destinations;
  final List<String> voice;

  OnboardingState copyWith({Set<Interest>? interests, Set<Destination>? destinations, List<String>? voice}) =>
      OnboardingState(interests: interests ?? this.interests, destinations: destinations ?? this.destinations, voice: voice ?? this.voice);
}

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final s = ref.read(settingsProvider);
    return OnboardingState(interests: s.interests, destinations: s.destinations, voice: s.voiceSamples);
  }

  void toggleInterest(Interest i) {
    final next = {...state.interests};
    next.contains(i) ? next.remove(i) : next.add(i);
    state = state.copyWith(interests: next);
  }

  void toggleDestination(Destination d) {
    final next = {...state.destinations};
    next.contains(d) ? next.remove(d) : next.add(d);
    state = state.copyWith(destinations: next);
  }

  void setVoice(List<String> samples) => state = state.copyWith(voice: samples);

  /// Saves answers. The router then goes to sign-in, then the photo picker (SPEC flow A).
  Future<void> finish() async {
    final s = ref.read(settingsProvider);
    await s.setInterests(state.interests);
    await s.setDestinations(state.destinations);
    await s.setVoiceSamples(state.voice);
    await s.setOnboardingDone(true);
    ref.read(appGateProvider).refresh();
  }
}

final onboardingControllerProvider = NotifierProvider<OnboardingController, OnboardingState>(OnboardingController.new);
