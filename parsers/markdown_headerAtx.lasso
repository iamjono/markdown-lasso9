define markdown_headerAtx => type { parent markdown_parser
    
    public onCreate(document::markdown_document, lines::staticarray) => {
        .document = #document
        
        local(line1) = #lines->first->asCopy

        if(not #line1->beginsWith("#")) => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(level) = #line1->size - #line1->removeLeading("#")&size

        .render   = '<h' + #level + '>' + markdown_inlineText(.document, (:#line1->removeTrailing('#')&trim&))->render + '</h' + #level + '>\n'
        .leftover = #lines->sub(2)
    }
}