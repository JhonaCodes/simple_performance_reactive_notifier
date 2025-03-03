import 'dart:developer';

import 'package:app/viewmodel/console_log.dart';
import 'package:flutter/material.dart';
import 'package:reactive_notifier/reactive_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TestScreen(),
      theme: ThemeData.dark(),
    );
  }
}

// Modelo simple de usuario
class User {
  final String id;
  final String name;
  String counter;

  User({
    required this.id,
    required this.name,
    this.counter = '0',
  });

  User copyWith({String? counter}) {
    return User(
      id: id,
      name: name,
      counter: counter ?? this.counter,
    );
  }

  void incrementCounter(String userId) {
    usersNotifier[userId]?.transformState((user) =>
        user.copyWith(counter: (int.parse(user.counter) + 1).toString()));
  }
}

// Notifier global para el mapa de usuarios
final Map<String, ReactiveNotifier<User>> usersNotifier = {
  'user1': ReactiveNotifier(() => User(id: 'user1', name: 'Usuario 1')),
  'user2': ReactiveNotifier(() => User(id: 'user2', name: 'Usuario 2')),
  'user3': ReactiveNotifier(() => User(id: 'user3', name: 'Usuario 3')),
};

// Screen de prueba
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    log("Data rebuild on main");
    return Scaffold(
      appBar: AppBar(
          title: Text('current notifiers: ${ReactiveNotifier.instanceCount}')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...usersNotifier.entries.map(
              (entry) => ReactiveBuilder(
                  notifier: entry.value,
                  builder: (user, keep) => UserCard(
                        user: user,
                        onIncrement: () =>
                            entry.value.notifier.incrementCounter(user.id),
                      )),
            ),
            ReactiveViewModelBuilder<FormStateData>(
              viewmodel: formStateNotifier.notifier,
              builder: (state, keep) {
                return Card(
                  child: Column(
                    children: [
                      Text(' ${state.submitState.name} '),
                      OutlinedButton(
                        onPressed: () {
                          if (state.submitState == SubmitState.failed) {
                            formStateNotifier.notifier
                                .setSubmitState(SubmitState.completed);
                          } else {
                            formStateNotifier.notifier
                                .setSubmitState(SubmitState.failed);
                          }
                        },
                        child: Text('Update'),
                      )

                      ///formStateNotifier
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   // usersNotifier['user1']?.transformState((usr) {
      //   //   final currentCount = int.parse(usr.counter);
      //   //   return usr.copyWith(counter: (currentCount + 1).toString());
      //   // });
      //
      //   TextEditingController d = TextEditingController();
      //   d.clear();
      //
      //   showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog.adaptive(
      //         title: Text('Text Dialog autodipose'),
      //         content: ReactiveBuilder(
      //             notifier: formStateNotifierDispose,
      //             builder: (state, keep) {
      //               return Column(
      //                 mainAxisSize: MainAxisSize.min,
      //                 children: [
      //                   Text(state.name),
      //                   keep(ElevatedButton(
      //                       onPressed: () {
      //                         formStateNotifierDispose
      //                             .updateState(SubmitState.invalid);
      //                       },
      //                       child: Text('FromDialog')))
      //                 ],
      //               );
      //             }),
      //       );
      //     },
      //   ).then((comp) {
      //     log(' has listeners ${formStateNotifierDispose.hasListeners}');
      //   });
      // }),
    );
  }
}

// Widget de tarjeta de usuario
class UserCard extends StatefulWidget {
  final User user;
  final VoidCallback onIncrement;

  const UserCard({
    required this.user,
    required this.onIncrement,
    super.key,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  final rebuildCount = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    log('UserCard initState: ${widget.user.id}');
  }

  @override
  Widget build(BuildContext context) {
    rebuildCount.value++;

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(widget.user.name),
        subtitle: Text('Contador: ${widget.user.counter}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Muestra cuántas veces se ha reconstruido este widget
            Text('Rebuilds: ${rebuildCount.value}'),
            const SizedBox(width: 8),
            // Botón para incrementar el contador
            ElevatedButton(
              onPressed: widget.onIncrement,
              child: const Text('+1'),
            ),
          ],
        ),
      ),
    );
  }
}

class FormStateData {
  final SubmitState submitState;
  final SubmitState presetState;
  final SubmitState deleteState;
  final String bidOfferOrAutoBidOffer;
  final bool counterPartyDestinationToggle;
  final Map<String, String>? errors;

  const FormStateData({
    this.submitState = SubmitState.valid,
    this.presetState = SubmitState.valid,
    this.deleteState = SubmitState.valid,
    this.bidOfferOrAutoBidOffer = '',
    this.counterPartyDestinationToggle = true,
    this.errors,
  });

  FormStateData copyWith({
    SubmitState? submitState,
    SubmitState? presetState,
    SubmitState? deleteState,
    String? bidOfferOrAutoBidOffer,
    bool? counterPartyDestinationToggle,
    Map<String, String>? errors,
  }) {
    return FormStateData(
      submitState: submitState ?? this.submitState,
      presetState: presetState ?? this.presetState,
      deleteState: deleteState ?? this.deleteState,
      bidOfferOrAutoBidOffer:
          bidOfferOrAutoBidOffer ?? this.bidOfferOrAutoBidOffer,
      counterPartyDestinationToggle:
          counterPartyDestinationToggle ?? this.counterPartyDestinationToggle,
      errors: errors ?? this.errors,
    );
  }
}

class FormStateVM extends ViewModel<FormStateData> {
  FormStateVM() : super(FormStateData());

  @override
  void init() {
    log('FormViewModel initialized');
    log('_submitState ${data.submitState}');
    log('_presetState ${data.presetState}');
    log('_deleteState ${data.deleteState}');
  }

  SubmitState get getSubmitState => data.submitState;

  void setSubmitState(SubmitState value) {
    updateState(data.copyWith(submitState: value));
  }

  SubmitState get getPresetState => data.presetState;

  void setPresetState(SubmitState value) {
    updateState(data.copyWith(presetState: value));
  }

  SubmitState get getDeleteState => data.deleteState;

  void setDeleteState(SubmitState value) {
    updateState(data.copyWith(deleteState: value));
  }

  Map<String, String>? get getErrors => data.errors;

  String? getError(String? field) {
    if (data.errors != null) {
      return data.errors![field];
    }
    return null;
  }

  void setErrors(Map<String, String>? value) {
    updateState(data.copyWith(errors: value));
  }

  String get getBidOfferOrAutoBidOffer => data.bidOfferOrAutoBidOffer;

  void setBidOfferOrAutoBidOfferState(String value) {
    updateState(data.copyWith(bidOfferOrAutoBidOffer: value));
  }

  bool get counterPartyDestinationToggle => data.counterPartyDestinationToggle;

  void setCounterPartyDestinationToggle(bool value) {
    updateState(data.copyWith(counterPartyDestinationToggle: value));
  }

  void reset() {
    updateState(FormStateData());
  }

  void refreshEntireFormState() {
    assert(() {
      if (WidgetsBinding.instance.buildOwner?.debugBuilding ?? false) {
        throw FlutterError(
            'refreshEntireFormState() called during build phase.\n'
            'This can lead to infinite rebuild loops and should be avoided.');
      }
      return true;
    }());
    notifyListeners();
  }

  FormStateVM forceUpdate() {
    return this;
  }

  @override
  void dispose() {
    log('Dispose from FormStateVM');

    super.dispose();
  }
}

enum SubmitState { invalid, valid, submit, failed, completed }

final formStateNotifier = ReactiveNotifierViewModel<FormStateVM, FormStateData>(
    FormStateVM.new,
    autoDispose: true);
final formStateNotifier2 = ReactiveNotifier<FormStateVM>(() => FormStateVM());
final formStateNotifierDispose =
    ReactiveNotifier<SubmitState>(() => SubmitState.completed);
