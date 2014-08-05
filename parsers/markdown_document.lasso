define markdown_document => type { parent markdown_parser
    data
        public lines::staticarray,
        public references,

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

    // Really should only be used for sub-parts of the document
    // Like for blockquotes or lists
    public onCreate(document::markdown_document, lines::staticarray) => {
        .lines      = #lines
        .leftover   = (:)
        .references = #document->references
    }
    public onCreate(source::string) => {
        local(regex) = regExp(
            -find  = `(?m)^[ ]{0,3}\[(.+)\]:[ \t]+<?(\S+?)>?(?:\s+[ \t]*["'(](.+?)["')])?[ \t]*$`,
            -input = #source
        )
        local(refs) = map

        while(#regex->find) => {
            local(id)    = #regex->matchString(1)
            local(url)   = #regex->matchString(2)
            local(title) = #regex->matchString(3)

            #refs->insert(#id = markdown_reference(#id, #url, #title))
            #regex->appendReplacement(``)
        }
        #regex->appendTail

        #source     = #regex->output
        .references = #refs

        .onCreate(self, regExp(-input=#source, -find=`\r\n|\r|\n`)->split)
    }


    public render => {
        if(.`render`->isNotA(::string)) => {
            local(result)   = ``
            local(unparsed) = .removeLeadingEmptyLines(.lines)
            local(size)     = #unparsed->size
            while(#size) => {

                loop(.parsers->size) => {
                    local(parser)  = .parsers->get(loop_count)
                    local(partial) = \(#parser)(self, #unparsed)

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