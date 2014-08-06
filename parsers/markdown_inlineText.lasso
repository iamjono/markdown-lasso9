define markdown_inlineText => type { parent markdown_parser
    data
        protected escapeCharacters = (:`\`, '`', `*`, `_`, `{`, `}`, `[`, `]`, `(`, `)`, `#`, `+`, `-`, `.`, `!`)
    
    public onCreate(document::markdown_document, lines::staticarray) => {
        .document = #document
        .leftover = (:)

        local(result) = #lines->join('\n')

        // Find inline code spans (``)
        local(regex) = regExp(-find='(?s)(`+)(.+?)(?<!`)\\1(?!`)', -input=#result)
        while(#regex->find) => {
            #regex->appendReplacement(
                '<code>' + .encodeCode(#regex->matchString(2))->trim& + '</code>'
            )
        }
        #regex->appendTail
        #result = #regex->output


        // Find inline images
        local(regex) = regExp(-find=`(?s)!\[(.*?)\]\([ \t]*<?(\S+?)>?([ \t]+(['"])(.*?)\4[ \t]*)?\)`, -input=#result)
        while(#regex->find) => {
            local(m1) = #regex->matchString(1)
            local(m2) = #regex->matchString(2)
            local(m5) = #regex->matchString(5)

            #regex->appendReplacement(
                `<img src="` + .escapeSpecialChars(#m2) + `" alt="` + .escapeSpecialChars(#m1) + `"` + 
                    (#m5? ` title="` + .escapeSpecialChars(#m5) + `"` | '') +` />`
            )
        }
        #regex->appendTail
        #result = #regex->output

        // Find referenced images
        local(regex) = regExp(-find=`(?s)!\[(.*?)\](?: |\n *)?\[(.*?)\]`, -input=#result)
        while(#regex->find) => {
            local(alt) = #regex->matchString(1)
            local(id)  = #regex->matchString(2)
            local(ref) = .document->references->find(#id)

            #ref
                ? #regex->appendReplacement(
                    `<img src="` + .escapeSpecialChars(#ref->url) + `" alt="` + .escapeSpecialChars(#alt) + `"` + 
                        (#ref->title? ` title="` + .escapeSpecialChars(#ref->title) | '') + `"` + " />"
                )
                | #regex->appendReplacement('$0')
        }
        #regex->appendTail
        #result = #regex->output


        // Find inline links
        local(regex) = regExp(-find=`(?s)\[(.*?)\]\([ \t]*<?(.*?)>?([ \t]+(['"])(.*?)\4)?\)`, -input=#result)
        while(#regex->find) => {
            local(m1) = #regex->matchString(1)
            local(m2) = #regex->matchString(2)
            local(m5) = #regex->matchString(5)

            #regex->appendReplacement(
                `<a href="` + .escapeSpecialChars(#m2) + `"` + (#m5? ` title="` + .escapeSpecialChars(#m5) + `"` | '') + `>` + .escapeSpecialChars(#m1) + `</a>`
            )
        }
        #regex->appendTail
        #result = #regex->output

        // Find referenced links
        local(regex) = regExp(-find=`(?s)\[(.*?)\](?: |\n *)?\[(.*?)\]`, -input=#result)
        while(#regex->find) => {
            local(txt) = #regex->matchString(1)
            local(id)  = #regex->matchString(2) || #txt
            local(ref) = .document->references->find(#id)

            #ref
                ? #regex->appendReplacement(
                    `<a href="` + .escapeSpecialChars(#ref->url) + `"` + (#ref->title? ` title="` + .escapeSpecialChars(#ref->title) + `"` | '') + `>` + .escapeSpecialChars(#txt) + `</a>`
                )
                | #regex->appendReplacement('$0')
        }
        #regex->appendTail
        #result = #regex->output

        // Find raw links in <>
        #result->replace(regExp(`<(https?://[^>\s]+)>`), `<a href="$1">$1</a>`)

        #result->replace(regExp(`<(?:mailto:)?([^@]+@[^@]+.[^@]+)>`), `<a href="mailto:$1">$1</a>`)
        
            


        #result->replace(' - ', ` \- `)
        #result->replace(' * ', ` \* `)

        #result->replace(regExp(`(?s)(?<!\\)\*\*(.*?)(?<!\\)\*\*`), `<strong>$1</strong>`)
        #result->replace(regExp(`(?s)\b(?<!\\)__(.*?)(?<!\\)__\b`), `<strong>$1</strong>`)
        
        #result->replace(regExp(`(?s)(?<!\\)\*(.*?)(?<!\\)\*`)  , `<em>$1</em>`)
        #result->replace(regExp(`(?s)\b(?<!\\)_(.*?)(?<!\\)_\b`), `<em>$1</em>`)

        // Encode ampersands and less thans
        #result->replace(regExp(`&(?!#?[xX]?(?:[0-9a-fA-F]+|\w+);)`), `&amp;`)
        #result->replace(regExp(`<(?![a-z/?\$!])`), `&lt;`, -ignoreCase)


        // Put in <br />s
        #result->replace("  \n", "<br />\n")

        .render = .unescapeSpecialChars(#result)
    }

    protected encodeCode(input::string) => {
        local(output) = #input->asCopy

        #output->replace('&', '&amp;')
        #output->replace('<', '&lt;')
        #output->replace('>', '&gt;')

        return .escapeSpecialChars(#output)
    }

    protected escapeSpecialChars(input::string) => {
        local(output) = #input->asCopy

        with char in .escapeCharacters do {
            #output->replace(#char, `\` + #char)
        }

        return #output
    }

    protected unescapeSpecialChars(input::string) => {
        local(output) = #input->asCopy

        with char in .escapeCharacters do {
            #output->replace(`\` + #char, #char)
        }

        return #output
    }
}