define markdown_listItem => type { parent markdown_parser
    data
        public isOrdered::boolean

    public onCreate(document::markdown_document, lines::staticarray, -ordered::boolean=false, -unordered::boolean=false) => {
        (not #ordered and not #unordered) or (#ordered and #unordered)
            ? fail(error_code_invalidParameter, "Must pass either -ordered or -unordered (and not both)")

        .document  = #document
        .isOrdered = #ordered

        .isOrdered
            ? local(regex_list) = regExp(`^ {0,3}\d+\.\s+(.*)$`)
            | local(regex_list) = regExp(`^ {0,3}[*+-]\s+(.*)$`)

        if(not #regex_list->setInput(#lines->first)&matches) => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(end)   = 1 // skip the first line
        local(block) = array(#regex_list->matchString(1))
        .render = '<li>\n'

        // First part doesn't need paragraph tag wrapped around it
        // - go until I hit an empty line or a list item (nested or otherwise)
        while(++#end <= #lines->size) => {
            local(line)          = #lines->get(#end)->asCopy
            local(cur_lineEmpty) = #line->asCopy->removeLeading('>')&trim& == ''

            #cur_lineEmpty or #regex_list->setInput(#line)&matches
                ? loop_abort

            #line->sub(1,1) == '\t'
                ? #line = #line->sub(2)
            | #line->beginsWith('    ')
                ? #line = #line->sub(5)

            #regex_list->setInput(#line)&matches
                ? loop_abort

            #block->insert(#line)
        }
        .render->append(markdown_inlineText(.document, #block->asStaticarray)->render + "\n")


        local(previous_line_empty) = true
        #end-- // back it up to get the possible empty line
        #block = array
        while(++#end <= #lines->size) => {
            local(line)          = #lines->get(#end)->asCopy
            local(cur_lineEmpty) = #line->asCopy->removeLeading('>')&trim& == ''

            #previous_line_empty and not #cur_lineEmpty and not (#line->beginsWith('\t') or #line->beginsWith('    '))
                ? loop_abort

            #cur_lineEmpty
                ? #block->insert('')
            | #line->sub(1,1) == '\t'
                ? #block->insert(#line->sub(2))
            | #line->beginsWith('    ')
                ? #block->insert(#line->sub(5))
            | #block->insert(#line)

            #previous_line_empty = #cur_lineEmpty
        }

        .render->append(markdown_document(.document, #block->asStaticarray)->render)
        .render->append('</li>\n')
        .leftover = #lines->sub(#end)
    }

    public isUnordered => not .isOrdered
    public isUnordered=(rhs::boolean) => {
        .isOrdered = not #rhs
        return #rhs
    }
}