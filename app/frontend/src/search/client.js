const searchClientKeyword = algoliasearch('QM2YE0HRBW', '20b88d28047d5e3d60437993ad3d9c50');

export const client = index => instantsearch({
    indexName: index,
    searchClient: searchClientKeyword,
    searchFunction(helper) {
        if (helper.state.query) {
            helper.search();
        }
    },
});