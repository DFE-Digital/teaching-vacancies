import ClipboardJS from 'clipboard'

$(document).ready(function(){
  new ClipboardJS('.copy-to-clipboard');

  $('.copy-to-clipboard').click(function(event) {
    event.preventDefault();
  });
});

fetch('https://localhost:3000/api/v1/coordinates/bdb2b077-9d58-4f19-9ac5-3b585105d7df').then(data => {
  return data.json()
})
.then(data => {
  console.log('data', data)
})
