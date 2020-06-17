export const onSubmit = (client) => {
  client.refresh();
};

export const getKeyword = () => document.querySelector('#keyword').value;
