define markdown_paragraph => type {
    data
        private render,
        private leftover

    public onCreate(lines::staticarray) => {
        local(line1) = #lines->first->asCopy

        if(#line1->asCopy->trim& == '') => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(end) = 0
        .render    = '<p>'

        while(++#end <= #lines->size) => {
            local(line) = #lines->get(#end)

            #line->asCopy->trim& == ''
                ? loop_abort
            #line->sub(1,2) == '> '
                ? loop_abort

            .render->append(#line + "\n")
        }

        .render->removeTrailing("\n")&append("</p>\n")
        .leftover = #lines->sub(#end)
    }


    public
        render   => .`render`,
        leftover => .`leftover`
}