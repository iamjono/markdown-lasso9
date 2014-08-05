define markdown_paragraph => type { parent markdown_parser

    public onCreate(document::markdown_document, lines::staticarray) => {
        .document = #document
        
        local(line1) = #lines->first->asCopy

        if(#line1->asCopy->trim& == '') => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(end)   = 0
        local(block) = array
        .render    = '<p>'

        while(++#end <= #lines->size) => {
            local(line) = #lines->get(#end)

            #line->asCopy->trim& == ''
                ? loop_abort
            #line->sub(1,2) == '> '
                ? loop_abort

            #block->insert(#line)
        }

        .render->append(markdown_inlineText(.document, #block->asStaticArray)->render + "</p>\n")
        .leftover = #lines->sub(#end)
    }
}