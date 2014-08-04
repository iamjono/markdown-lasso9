define markdown_parser => type {
    data
        protected render,
        protected leftover

    public
        render   => .`render`,
        leftover => .`leftover`

    public onCreate(lines::staticarray) => {
        .render   = ''
        .leftover = #lines
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