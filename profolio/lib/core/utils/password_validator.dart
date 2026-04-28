enum PasswordStrength { weak, fair, good, strong }

class PasswordValidator {
  static const int minLength = 8;
  
  static PasswordStrength calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    
    int strength = 0;
    
    if (password.length >= minLength) strength++;
    
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    if (strength <= 1) return PasswordStrength.weak;
    if (strength <= 2) return PasswordStrength.fair;
    if (strength <= 3) return PasswordStrength.good;
    return PasswordStrength.strong;
  }
  
  static bool hasMinLength(String pwd) => pwd.length >= minLength;
  static bool hasLowercase(String pwd) => RegExp(r'[a-z]').hasMatch(pwd);
  static bool hasUppercase(String pwd) => RegExp(r'[A-Z]').hasMatch(pwd);
  static bool hasNumber(String pwd) => RegExp(r'[0-9]').hasMatch(pwd);
  static bool hasSpecialChar(String pwd) => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd);
  
  static bool isStrong(String pwd) {
    return hasMinLength(pwd) && 
           hasLowercase(pwd) && 
           hasUppercase(pwd) && 
           hasNumber(pwd) && 
           hasSpecialChar(pwd);
  }
}