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

        local(regex_embeded_list) = regExp(`^(?:\t|    )(?:[*+-]|\d+\.)\s`)

        while(++#end <= #lines->size) => {
            local(line) = #lines->get(#end)

            #line->asCopy->trim& == ''
                ? loop_abort
            #line->sub(1,2) == '> '
                ? loop_abort

            // We want to trim off all the indentation for the embeded lists.
            // This is so they don't show up as pre-formatted text when parsed.
            // Since pre-formatted text must be seperated by a blank line, this
            // shouldn't cause any unwanted behavior.
            if(#regex_embeded_list->setInput(#line)&matchesStart) => {
                local(position) = #end
                #line->trim

                while(++#position <= #lines->size) => {
                    #line = #lines->get(#position)

                    not #regex_embeded_list->setInput(#line)&matchesStart
                        ? loop_abort

                    #line->trim
                }

                loop_abort
            }

            #block->insert(#line)
        }

        .render->append(markdown_inlineText(.document, #block->asStaticArray)->render + "</p>\n")
        .leftover = #lines->sub(#end)
    }
}