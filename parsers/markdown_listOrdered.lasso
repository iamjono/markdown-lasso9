define markdown_listOrdered => type { parent markdown_parser

    public onCreate(document::markdown_document, lines::staticarray) => {
        .document = #document
        .render   = '<ul>\n'
        
        //keep rendering list item
        local(line)
        while(#lines->size) => {
            #line = markdown_listItem(.document, #lines, -ordered)

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