define markdown_listOrdered => type { parent markdown_parser

    public onCreate(lines::staticarray) => {
        .render   = '<ul>\n'
        
        //keep rendering list item
        local(line)
        while(#lines->size) => {
            #line = markdown_listItem(#lines, -ordered)

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
}