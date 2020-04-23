export const search = algoliasearch('', '')

// TODO remove all this global scope
export const client = indexName => instantsearch({
    indexName: indexName,
    searchClient: search,
    searchFunction(helper) {
        if (helper.state.query) {
            helper.search();
        }
    },
})

export const index = indexName => search.initIndex(indexName)