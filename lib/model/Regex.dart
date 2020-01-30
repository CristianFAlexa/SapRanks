class Regex {
  static final RegExp number = new RegExp(r'^[1-9][0-9]?$');
  static final RegExp xp = new RegExp(r'^[1-9][0-9]?[0-9]?$');
  static final RegExp password = new RegExp(r'^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\\S+$).{8,}$');
  static final RegExp email =
      new RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$');
}
