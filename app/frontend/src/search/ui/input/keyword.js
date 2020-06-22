export const onSubmit = (client) => {
  client.helper.setPage(0); // if the search input changes, the page should be reset to 0
  client.refresh();
};

export const getKeyword = () => document.querySelector('#keyword').value;
