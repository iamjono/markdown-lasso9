define markdown_blockquote => type {
    data
        private render,
        private leftover

    public onCreate(lines::staticarray) => {
        local(line1) = #lines->first
        if(not #line1->beginsWith('> ')) => {
            .render   = ''
            .leftover = #lines
            return
        }

        .render      = '<blockquote>\n'
        local(end)   = 0
        local(block) = array
        local(previous_line_empty) = false

        while(++#end <= #lines->size) => {
            local(line)          = #lines->get(#end)->asCopy
            local(cur_lineEmpty) = #line->asCopy->removeLeading('>')&trim& == ''

            #previous_line_empty and not #cur_lineEmpty and not #line->beginsWith('> ')
                ? loop_abort

            #cur_lineEmpty
                ? #block->insert('')
            | #line->sub(1,2) == '> '
                ? #block->insert(#line->sub(3))
                | #block->insert(#line)

            #previous_line_empty = #cur_lineEmpty
        }
        .render->append(markdown_document(#block->asStaticarray)->render)
        .render->append('</blockquote>\n')
        .leftover = #lines->sub(#end)
    }


    public
        render   => .`render`,
        leftover => .`leftover`
}