/* eslint-disable */
/**
 * @param "arr" (required) - array-like or iterable object to convert it to an array.
 * @param "callbackFn" (optional) - function to call on every element of the array.
 * @param "thisArg" (optional) - value to use as this when executing callback
 * Return value - new Array instance
 *
 * The callbackFn argument usage is like in Array.map() callback.
 * The callbackFn function accepts the following arguments:
 *      @param "currentValue" (required) - the current element being processed in the array.
 *      @param "index" (optional) - the index of the current element being processed in the array.
 *      @param "array" (optional) - he array map was called upon.
 * Callback function that is called for every element of "arr". Each time callback executes, the returned value is added to new array ("arNew").
 */
function arrayFrom(arr, callbackFn, thisArg) {
  // if you need you can uncomment the following line
  // if(!arr || typeof arr == 'function')throw new Error('This function requires an array-like object - not null, undefined or a function');

  var arNew = [];
  var k = []; // used for convert Set to an Array
  var i = 0;

  // if you do not need a Set object support then
  // you can comment or delete the following if statement
  if (window.Set && arr instanceof Set) {
    // we use forEach from Set object
    arr.forEach(function (v) { k.push(v) });
    arr = k
  }

  for (; i < arr.length; i++)
    arNew[i] = callbackFn
      ? callbackFn.call(thisArg, arr[i], i, arr)
      : arr[i];

  return arNew
}

//You could also use it without the following line, but it is not recommended because native function is faster.
Array.from = Array.from || arrayFrom; //We set it as polyfill
