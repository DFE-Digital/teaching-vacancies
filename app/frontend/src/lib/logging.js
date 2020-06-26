import Rollbar from 'rollbar';

const rollbar = new Rollbar({
  accessToken: '14fb3641a126437ab1d29cf52357c192',
  captureUncaught: true,
  captureUnhandledRejections: true
});

rollbar.configure({reportLevel: 'warning'});

export default rollbar;
