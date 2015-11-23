define markdown_hr => type { parent markdown_parser

    public onCreate(document::markdown_document, lines::staticarray) => {
        .document = #document
        
        local(line1) = #lines->first

        if(
            regExp(-input=#line1, -find=`^-\s*-\s*-(-|\s)*$`)->matches or
            regExp(-input=#line1, -find=`^_\s*_\s*_(_|\s)*$`)->matches or
            regExp(-input=#line1, -find=`^\*\s*\*\s*\*(\*|\s)*$`)->matches
        ) => {
            .render   = '<hr />'
            .leftover = #lines->sub(2)
        else
            .render   = ''
            .leftover = #lines
        }
    }
}