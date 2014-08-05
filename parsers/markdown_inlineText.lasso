define markdown_inlineText => type { parent markdown_parser
    data
        protected escapeCharacters = (:`*`, `_`, `{`, `}`, `[`, `]`, `\`)
    
    public onCreate(lines::staticarray) => {
        .leftover = (:)

        local(result) = #lines->join('\n')

        // Find inline code spans (``)
        local(my_regexp) = regExp(-find='(?s)(`+)(.+?)(?<!`)\\1(?!`)', -input=#result)
        while(#my_regexp->find) => {
            #my_regexp->appendReplacement(
                '<code>' + .encodeCode(#my_regexp->matchString(2))->trim& + '</code>'
            )
        }
        #my_regexp->appendTail
        #result = #my_regexp->output


        // Find inline images
        local(my_regexp) = regExp(-find=`(?s)!\[(.*?)\]\([ \t]*<?(\S+?)>?([ \t]+(['"])(.*?)\4[ \t]*)?\)`, -input=#result)
        while(#my_regexp->find) => {
            local(m1) = .escapeSpecialChars(#my_regexp->matchString(1) || '')
            local(m2) = .escapeSpecialChars(#my_regexp->matchString(2) || '')
            local(m5) = .escapeSpecialChars(#my_regexp->matchString(5) || '')

            #my_regexp->appendReplacement(
                `<img src="` + #m2 + `" alt="` + #m1 + `"` + (#my_regexp->matchString(5)? ` title="` + #m5 + `"` | '') +` />`
            )
        }
        #my_regexp->appendTail
        #result = #my_regexp->output


        // Find inline links
        local(my_regexp) = regExp(-find=`(?s)\[(.*?)\]\([ \t]*<?(.*?)>?([ \t]+(['"])(.*?)\4)?\)`, -input=#result)
        while(#my_regexp->find) => {
            local(m1) = .escapeSpecialChars(#my_regexp->matchString(1) || '')
            local(m2) = .escapeSpecialChars(#my_regexp->matchString(2) || '')
            local(m5) = .escapeSpecialChars(#my_regexp->matchString(5) || '')

            #my_regexp->appendReplacement(
                `<a href="` + #m2 + `"` + (#my_regexp->matchString(5)? ` title="` + #m5 + `"` | '') + `>` + #m1 + `</a>`
            )
        }
        #my_regexp->appendTail
        #result = #my_regexp->output


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