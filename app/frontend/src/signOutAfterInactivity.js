var timeoutInMinutes = 30

var timeoutId; 

function resetTimer() { 
    window.clearTimeout(timeoutId)
    startTimer();
}

function clickSignOut() {
    document.getElementById('sign_out').click();
}

function startTimer() { 
    var timeoutInMilliseconds = timeoutInMinutes * 60000;
    timeoutId = window.setTimeout(clickSignOut, timeoutInMilliseconds)
}
 
function setupTimers () {
    document.addEventListener("mousemove", resetTimer, false);
    document.addEventListener("mousedown", resetTimer, false);
    document.addEventListener("keypress", resetTimer, false);
    document.addEventListener("touchmove", resetTimer, false);
     
    startTimer();
}

setupTimers();
