part of 'sign_up_form_bloc.dart';

class SignUpFormState with ValformMixin {
  final VfReproduce<String> emailApiErrorVf;
  final MultiVfExpel invalidateFormVf;

  @override
  List<Valform> get valforms => [emailApiErrorVf, invalidateFormVf];

  final bool isSubmitting;

  SignUpFormState({
    required this.isSubmitting,
    this.emailApiErrorVf = const VfReproduce.sealed(),
    this.invalidateFormVf = const MultiVfExpel.sealed(),
  });

  factory SignUpFormState.initialState() => SignUpFormState(
        isSubmitting: false,
      );

  SignUpFormState copyWith({
    bool? isSubmitting,
    VfReproduce<String>? emailApiErrorVf,
    MultiVfExpel? invalidateFormVf,
  }) {
    return SignUpFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailApiErrorVf: emailApiErrorVf ?? this.emailApiErrorVf,
      invalidateFormVf: invalidateFormVf ?? this.invalidateFormVf,
    );
  }

  String? validateEmail(String? email) {
    final emailApiError = emailApiErrorVf.access(email);
    final isInvalidated = invalidateFormVf.access(email, fieldId: "email");

    if (isInvalidated) {
      return null;
    } else if (emailApiError != null) {
      return emailApiError;
    } else if (email != null) {
      const errorText = "Incorrect format";
      if (email.contains("@")) {
        final split = email.split("@");
        return split.length == 2 &&
                split.every((element) => !element.contains("@") & element.isNotEmpty)
            ? null
            : errorText;
      }
      return errorText;
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (invalidateFormVf.access(password, fieldId: "password")) {
      return null;
    } else if (password == null || password.length < 8) {
      return "Too short";
    } else {
      return null;
    }
  }

  String? validateConfirmedPassword(String? confirmedPassword, String? password) {
    if (invalidateFormVf.access(password, fieldId: "password-confirm")) {
      return null;
    } else if (password != confirmedPassword) {
      return "Passwords should be equal";
    } else {
      return null;
    }
  }
}
