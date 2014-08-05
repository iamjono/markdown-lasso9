local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_listUnordered) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match an unordered list`) => {
            local(code) = markdown_listUnordered((:"    *"))
            expect('', #code->render)

            local(code) = markdown_listUnordered((:"*miss space"))
            expect('', #code->render)
        }

        it(`returns an html ul if passed lines matching markdown unordered list`) => {
            local(code) = markdown_listUnordered((:"* nice"))
            expect('<ul>\n<li>\nnice\n</li>\n</ul>\n', #code->render)
        }

        it(`correctly parses multiple list items`) => {
            local(code) = markdown_listUnordered((:
                " * an item",
                " * another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)

            local(code) = markdown_listUnordered((:
                "+ an item",
                "+ another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)

            local(code) = markdown_listUnordered((:
                "   - an item",
                "   - another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)
        }

        it(`correctly parses multiple list items with blank lines`) => {
            local(code) = markdown_listUnordered((:
                "  - an item",
                "",
                "",
                "  - another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not an unordered list`) => {
            local(code) = markdown_listUnordered((:"    *"))
            expect((:"    *"), #code->leftover)
        }

        it(`returns an empty staticarray if all lines are part of unordered list`) => {
            local(code) = markdown_listUnordered((:
                "  - an item",
                "  - another",
                "",
                " - third"
            ))
            expect((:), #code->leftover)
        }

        it(`returns a staticarray without the unordered list lines`) => {
            local(code) = markdown_listUnordered((:
                "   - an item",
                "   - another",
                "",
                "here"
            ))
            expect((:"here"), #code->leftover)
        }
    }
}