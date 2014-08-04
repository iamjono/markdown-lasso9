define markdown_document => type { parent markdown_parser
    data
        public lines::staticarray,

        private parsers = (:
            ::markdown_hr,
            ::markdown_codeblock,
            ::markdown_blockquote,
            ::markdown_html,
            ::markdown_headerAtx,
            ::markdown_listOrdered,
            ::markdown_listUnordered,
            ::markdown_headerSetext,
            ::markdown_paragraph
        )

    public onCreate(lines::staticarray) => {
        .lines    = #lines
        .leftover = (:)
    }


    public render => {
        if(.`render`->isNotA(::string)) => {
            local(result)   = ``
            local(unparsed) = .removeLeadingEmptyLines(.lines)
            local(size)     = #unparsed->size
            while(#size) => {

                loop(.parsers->size) => {
                    local(parser)  = .parsers->get(loop_count)
                    local(partial) = \(#parser)(#unparsed)

                    #partial->render == ''
                        ? loop_continue

                    #result->append(#partial->render)
                    #unparsed = .removeLeadingEmptyLines(#partial->leftover)
                    loop_abort
                }

                #size == #unparsed->size
                    ? fail("Could not parse the document")

                #size = #unparsed->size
            }
            .`render` = #result
        }
        return .`render`
    }
}