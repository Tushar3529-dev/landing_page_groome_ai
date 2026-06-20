part of 'contact_cubit.dart';

sealed class ContactState extends Equatable {
  const ContactState();

  @override
  List<Object?> get props => [];
}

final class ContactInitial extends ContactState {
  const ContactInitial();
}

final class ContactLoading extends ContactState {
  const ContactLoading();
}

final class ContactSuccess extends ContactState {
  const ContactSuccess();
}

final class ContactFailure extends ContactState {
  const ContactFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
