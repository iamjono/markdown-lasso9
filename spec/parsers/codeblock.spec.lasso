local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke
// TODO: Test for html escaping & < >
describe(::markdown_codeblock) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match a codeblock`) => {
            local(code) = markdown_codeblock((:'  oops'))
            expect('', #code->render)
        }
        it(`returns an html codeblock if passed lines matching markdown codeblock`) => {
            local(code) = markdown_codeblock((:"    if(true)"))
            expect("<pre><code>if(true)\n</code></pre>", #code->render)

            local(code) = markdown_codeblock((:"\tif(true)"))
            expect("<pre><code>if(true)\n</code></pre>", #code->render)
        }
        it(`correctly parses multiple codeblock lines`) => {
            local(code) = markdown_codeblock((:
                "\tlocal(a) = 3",
                "\tlocal(b) = #a",
                "    local(c) = #b"
            ))
            expect("<pre><code>local(a) = 3\n" + 
                    "local(b) = #a\n"
                    "local(c) = #b\n</code></pre>",
                #code->render
            )
        }

        it(`correctly parses multiple codeblock lines with blank lines`) => {
            local(code) = markdown_codeblock((:
                "\tlocal(a) = 3",
                "\tlocal(b) = #a",
                "   ",
                "",
                "\tlocal(c) = #b"
            ))
            expect("<pre><code>local(a) = 3\n" + 
                    "local(b) = #a\n\n\n"
                    "local(c) = #b\n</code></pre>",
                #code->render
            )
        }

        it(`correctly parses multiple codeblock lines with indented lines`) => {
            local(code) = markdown_codeblock((:
                "\tlocal(a) = 3",
                "\tlocal(b) = #a",
                "\t\t",
                "",
                "\tif(#a == #b) => {",
                "\t\tlocal(c) = #b",
                "        #a++",
                "    }"
            ))
            expect("<pre><code>local(a) = 3\n" + 
                    "local(b) = #a\n\n\n"
                    "if(#a == #b) => {\n" + 
                    "\tlocal(c) = #b\n" + 
                    "    #a++\n"
                    "}\n</code></pre>",
                #code->render
            )
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not a codeblock`) => {
            local(code) = markdown_codeblock((:'  oops'))
            expect((:'  oops'), #code->leftover)
        }

        it(`returns an empty staticarray if all lines are codeblocks`) => {
            local(code) = markdown_codeblock((:
                "\tlocal(a) = 3",
                "\tlocal(b) = #a",
                "\t\t",
                "",
                "\tif(#a == #b) => {",
                "\t\tlocal(c) = #b",
                "        #a++",
                "    }"
            ))
            expect((:), #code->leftover)
        }

        it(`returns a staticarray without the codeblock lines`) => {
            local(code) = markdown_codeblock((:"    if(true)", "here"))

            expect((:"here"), #code->leftover)
        }
    }
}