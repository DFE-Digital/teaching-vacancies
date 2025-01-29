import { Cookie } from 'tough-cookie';

const cookies = document.cookie.split(';').map(Cookie.parse);

// change clarity consent cookie value from default 'yes' to 'clarity'
// to remind ourselves that we have called the clarity consent API
cookies.forEach((cookie) => {
  if (cookie && cookie.name === 'consented-to-additional-cookies-v2' && cookie.value === 'yes') {
    cookie.value = 'clarity';
    window.clarity('consent');
    document.cookie = cookie.toString();
  }
});
