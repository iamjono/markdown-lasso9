define markdown_reference => type {
    data
        public id,
        public url,
        public title

    public onCreate(id, url, title) => {
        .id    = #id
        .url   = #url
        .title = #title
    }
}