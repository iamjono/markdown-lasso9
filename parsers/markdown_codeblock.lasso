define markdown_codeblock => type { parent markdown_parser

    public onCreate(document::markdown_document, lines::staticarray) => {
        .document = #document
        .render   = ''

        local(line1) = #lines->first
        if(
            not #line1->beginsWith("\t") and
            not #line1->beginsWith("    ")
        ) => {
            .leftover = #lines
            return
        }

        local(end)  = 0
        local(text) = ``
        .render->append(`<pre><code>`)

        while(++#end <= #lines->size) => {
            local(line) = #lines->get(#end)->asCopy

            #line->asCopy->trim& == ''
                ? #text->append("\n")
            |#line->beginsWith("    ")
                ? #text->append(#line->sub(5) + "\n")
            | #line->beginsWith("\t")
                ? #text->append(#line->sub(2) + "\n")
            | loop_abort
        }

        #text->replace('&', "&amp;")&replace('<', "&lt;")&replace('>', "&gt;")
        .render->append(#text + `</code></pre>`)
        .leftover = #lines->sub(#end)
    }
}