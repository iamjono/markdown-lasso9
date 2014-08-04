define markdown_codeblock => type { parent markdown_parser

    public onCreate(lines::staticarray) => {
        .render = ''

        local(line1) = #lines->first
        if(
            not #line1->beginsWith("\t") and
            not #line1->beginsWith("    ")
        ) => {
            .leftover = #lines
            return
        }

        local(end) = 0
        .render->append(`<pre><code>`)

        while(++#end <= #lines->size) => {
            local(line) = #lines->get(#end)->asCopy

            #line->asCopy->trim& == ''
                ? .render->append("\n")
            |#line->beginsWith("    ")
                ? .render->append(#line->sub(5) + "\n")
            | #line->beginsWith("\t")
                ? .render->append(#line->sub(2) + "\n")
            | loop_abort
        }

        .render->append(`</code></pre>`)
        .leftover = #lines->sub(#end)
    }
}