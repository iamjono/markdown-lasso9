local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_html) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match an html block`) => {
            local(html) = markdown_html((:"< nope"))
            expect("", #html->render)
        }
        it(`returns an html block if passed lines matching markdown codeblock`) => {
            local(html) = markdown_html((:
                `<div class="foo">`,
                `<div id="bar"></div>`,
                `</div>`
            ))
            expect(
                `<div class="foo">` + "\n" +
                    `<div id="bar"></div>` + "\n" +
                    `</div>` + "\n",
                #html->render
            )
        }
        
        it(`correctly parses html block with blank lines`) => {
            local(html) = markdown_html((:
                `<div class="foo">`,
                '',
                ``,
                `<div id="bar"></div>`,
                ' \t',
                `</div>`
            ))
            expect(
                `<div class="foo">` + "\n\n\n" +
                    `<div id="bar"></div>` + "\n\n" +
                    `</div>` + "\n",
                #html->render
            )
        }

        it(`correctly parses html block with indented lines`) => {
            local(html) = markdown_html((:
                `<div class="foo">`,
                `    <div id="bar"></div>`,
                '\t<p></p>',
                `</div>`
            ))
            expect(
                `<div class="foo">` + "\n" +
                    `    <div id="bar"></div>` + "\n" +
                    '\t<p></p>\n' +
                    `</div>` + "\n",
                #html->render
            )
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not an html block`) => {
            local(html) = markdown_html((:"< nope"))
            expect((:"< nope"), #html->leftover)
        }

        it(`returns an empty staticarray if all lines are an html block`) => {
            local(html) = markdown_html((:
                `<div class="foo">`,
                '\t ',
                `    <div id="bar"></div>`,
                ' ',
                '\t<p></p>',
                `</div>`
            ))
            expect((:), #html->leftover)
        }

        it(`returns a staticarray without the html block lines`) => {
            local(html) = markdown_html((:
                `<div class="foo">`,
                `</div>`,
                'here'
            ))
            expect((:'here'), #html->leftover)
        }
        it(`returns a staticarray without the html block lines even when opening block is two tags`) => {
            local(html) = markdown_html((:
                `<div><p>`,
                `</p>`,
                `</div>`,
                'here'
            ))
            expect((:'here'), #html->leftover)
        }
    }
}