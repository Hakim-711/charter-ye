export function isStrongPassword(value) {
  if (typeof value !== 'string') {
    return false;
  }
  const password = value.trim();
  const hasMinLength = password.length >= 10;
  const hasUpper = /[A-Z]/.test(password);
  const hasLower = /[a-z]/.test(password);
  const hasDigit = /[0-9]/.test(password);
  const hasSymbol = /[^A-Za-z0-9]/.test(password);
  return hasMinLength && hasUpper && hasLower && hasDigit && hasSymbol;
}
