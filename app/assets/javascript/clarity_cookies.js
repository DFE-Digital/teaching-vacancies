import { Cookie } from 'tough-cookie';

const cookies = document.cookie.split(';').map(Cookie.parse);

// change clarity consent cookie value from default 'yes' to 'clarity'
// to remind ourselves that we have called the clarity consent API
cookies.forEach((cookie) => {
  if (cookie && cookie.name === 'consented-to-additional-cookies-v3' && cookie.value === 'yes') {
    cookie.value = 'clarity';
    window.clarity('consentv2', { ad_Storage: 'granted', analytics_Storage: 'granted' });
    document.cookie = cookie.toString();
  }
});
