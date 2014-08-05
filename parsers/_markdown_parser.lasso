define markdown_parser => type {
    data
        protected render,
        protected leftover,
        protected document

    public
        render   => .`render`,
        leftover => .`leftover`,
        document => .`document`

    public onCreate(document::markdown_document, lines::staticarray) => {
        .render   = ''
        .leftover = #lines
        .document = #document
        .onCreate(#lines)
    }

    protected removeLeadingEmptyLines(lines::staticarray) => {
        local(i)    = 1
        local(size) = #lines->size 
        while(#i <= #size and #lines->get(#i)->asCopy->trim& == '') => {
            #i++
        }

        return #lines->sub(#i)
    }
}