function removeCommaFromNumber(number) {
  return number.replace(/,/g, '');
}

// Exposing function to window to let teaspoon specs pass
// TODO: remove this after removing teaspoon
window.removeCommaFromNumber = removeCommaFromNumber
