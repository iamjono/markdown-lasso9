define markdown_headerAtx => type { parent markdown_parser
    
    public onCreate(lines::staticarray) => {
        local(line1) = #lines->first->asCopy

        if(not #line1->beginsWith("#")) => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(level) = #line1->size - #line1->removeLeading("#")&size

        .render   = '<h' + #level + '>' + markdown_inlineText((:#line1->trim&))->render + '</h' + #level + '>\n'
        .leftover = #lines->sub(2)
    }
}