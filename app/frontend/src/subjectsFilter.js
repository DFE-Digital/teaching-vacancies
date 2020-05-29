document.addEventListener('DOMContentLoaded', function() {
  var subjectFilter, filteredSubjectNames, filteredSubjectHints;
  var checkedSubjectElements = [];
  var duplicateSubjectElements = [];

  const subjectSearchInput = document.getElementById('job-specification-form-subject-search');
  const subjectElements = document.querySelector('.checkboxes-with-scroll.subjects-options');

  if (subjectElements) {
    const subjectArray = [...subjectElements.children];
    subjectArray.shift();
    const subjectNames = subjectArray.map(ele => ele.children[1].textContent.toLowerCase());
    const subjectHints = subjectArray.map(ele => ele.children.length > 2 ? ele.children[2].textContent.toLowerCase() : undefined);
    const subjectCheckboxes = document.querySelectorAll('.subjects-options > .govuk-checkboxes__item > input');

    subjectSearchInput.addEventListener('input', function(v) {
      subjectFilter = subjectSearchInput.value.toLowerCase();
      filteredSubjectNames = subjectNames.filter(function(a) {
        return a.indexOf(subjectFilter) > -1;
      });
      filteredSubjectHints = subjectHints.filter(function(a) {
        return a == undefined ? false : a.indexOf(subjectFilter) > -1;
      });

      for (var i = 0; i < subjectArray.length; i++) {
        var element = subjectArray[i];
        displayElement(element) ? element.style.display = 'block' : element.style.display = 'none';
      }
    });

    [...subjectCheckboxes].forEach(function(checkbox) {
      if (checkbox.checked) {
        manipulateCheckedElement(checkbox);
      }

      checkbox.addEventListener('change', function() {
        if (this.checked) {
          manipulateCheckedElement(this);
        }
      });
    });

    document.querySelector('.js-checkbox').classList.remove('display-none');
    document.querySelector('.subjects-options').classList.remove('js-disabled-border');
  }

  function displayElement(element) {
    var elementName = element.children[1].textContent.toLowerCase();
    var elementHint = element.children.length > 2 ? element.children[2].textContent.toLowerCase() : '';
    var duplicateCheckedElement = duplicateSubjectElements.find(function(ele) {
      return ele.children[1].textContent == element.children[1].textContent;
    });
    if ((filteredSubjectNames.indexOf(elementName) > -1 ||
         filteredSubjectHints.indexOf(elementHint) > -1 ||
         element.children[0].checked) && !duplicateCheckedElement) {
      return true;
    } else {
      return false;
    }
  }

  function manipulateCheckedElement(checkbox) {
    checkedSubjectElements.push(checkbox.parentElement);
    var duplicateElement = checkbox.parentElement.cloneNode(true);
    duplicateElement.addEventListener('change', function() {
      if (!this.checked) {
        var originalElement = checkedSubjectElements.find(function(ele) {
          return ele.children[1].textContent == duplicateElement.children[1].textContent;
        });
        originalElement.style.display = 'block';
        duplicateSubjectElements.splice(duplicateSubjectElements.indexOf(duplicateElement), 1);
        this.remove();
      }
    });
    duplicateSubjectElements.push(duplicateElement);
    subjectElements.insertBefore(duplicateElement, subjectElements.children[1]);
    checkbox.checked = false;
    checkbox.parentElement.style.display = 'none';
  }
});
