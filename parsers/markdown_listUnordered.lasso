define markdown_listUnordered => type {
    data
        private render,
        private leftover

    public onCreate(lines::staticarray) => {
        .render   = '<ul>\n'
        
        //keep rendering list item
        local(line)
        while(#lines->size) => {
            #line = markdown_listItem(#lines, -unordered)

            #line->render == ''
                ? loop_abort

            .render->append(#line->render)

            #lines = .removeLeadingEmptyLines(#line->leftover)
        }
        
        .leftover = #lines
        .render == '<ul>\n'
            ? .render = ''
            | .render->append('</ul>\n')
    }

    public
        render   => .`render`,
        leftover => .`leftover`

    private removeLeadingEmptyLines(lines::staticarray) => {
        local(i)    = 1
        local(size) = #lines->size 
        while(#i <= #size and #lines->get(#i)->asCopy->trim& == '') => {
            #i++
        }

        return #lines->sub(#i)
    }
}