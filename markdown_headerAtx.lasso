define markdown_headerAtx => type {
    data
        private render,
        private leftover

    public onCreate(lines::staticarray) => {
        local(line1) = #lines->first->asCopy

        if(not #line1->beginsWith("#")) => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(level) = #line1->size - #line1->removeLeading("#")&size

        .render   = '<h' + #level + '>' + #line1->trim& + '</h' + #level + '>\n'
        .leftover = #lines->sub(2)
    }


    public
        render   => .`render`,
        leftover => .`leftover`
}