
class ErrorCodes {


  static String genLogInErrorMessage(String error) {

    switch (error) {
      case 'invalid-email':
        return 'Correo inválido. Por favor escribe un correo válido';
        break;
      case 'wrong-password':
        return 'La contraseña es incorrecta';
        break;
      case 'user-disabled':
        return 'Esta cuenta ha sido desactivada. Por favor contacte al equipo de soporte técnico';
        break;
      case 'user-not-found':
        return 'No hay un usuario asociado al correo electrónico';
        break;
      default:
        return 'Hubo un error al iniciar sesión';
    }
  }

  static String genSignUpErrorMessage(String error) {

    switch (error) {
      case 'invalid-email':
        return 'Correo inválido. Por favor escribe un correo válido';
        break;
      case 'email-already-in-use':
        return 'Este correo ya es usado por otra cuenta';
        break;
    case 'weak-password':
        return 'La contraseña debe contener al menos 6 caracteres';
        break;
      default:
        return 'Hubo un error al crear cuenta';
    }
  }

}