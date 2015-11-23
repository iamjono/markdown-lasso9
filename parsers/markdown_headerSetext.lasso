define markdown_headerSetext => type { parent markdown_parser

    public onCreate(document::markdown_document, lines::staticarray) => {
        .document = #document
        
        local(line1) = #lines->first->asCopy
        local(line2) = #lines->second

        if(not #line1 or not #line2 or not regExp(-input=#line2, -find=`^(=+|-+)\s*$`)->matches) => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(level) = (#line2->sub(1,1) == '-' ? 2 | 1)

        .render   = '<h' + #level + '>' + markdown_inlineText(.document, (:#line1->trim&))->render + '</h' + #level + '>\n'
        .leftover = #lines->sub(3)
    }
}