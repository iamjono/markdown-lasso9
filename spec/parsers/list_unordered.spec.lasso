local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

local(document) = markdown_document(``)

describe(::markdown_listUnordered) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match an unordered list`) => {
            local(code) = markdown_listUnordered(#document, (:"    *"))
            expect('', #code->render)

            local(code) = markdown_listUnordered(#document, (:"*miss space"))
            expect('', #code->render)
        }

        it(`returns an html ul if passed lines matching markdown unordered list`) => {
            local(code) = markdown_listUnordered(#document, (:"* nice"))
            expect('<ul>\n<li>\nnice\n</li>\n</ul>\n', #code->render)
        }

        it(`correctly parses multiple list items`) => {
            local(code) = markdown_listUnordered(#document, (:
                " * an item",
                " * another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)

            local(code) = markdown_listUnordered(#document, (:
                "+ an item",
                "+ another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)

            local(code) = markdown_listUnordered(#document, (:
                "   - an item",
                "   - another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)
        }

        it(`correctly parses multiple list items with blank lines`) => {
            local(code) = markdown_listUnordered(#document, (:
                "  - an item",
                "",
                "",
                "  - another"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ul>\n', #code->render)
        }

        it(`correctly parses nested lists with the same list symbol`) => {
            local(code) = markdown_listUnordered(#document, (:
                "* an item",
                "* another",
                "\t* sub1",
                "\t* sub2",
                "* last"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n<ul>\n<li>\nsub1\n</li>\n<li>\nsub2\n</li>\n</ul>\n</li>\n<li>\nlast\n</li>\n</ul>\n', #code->render)
        }

        it(`correctly parses nested lists with different list symbol`) => {
            local(code) = markdown_listUnordered(#document, (:
                "* an item",
                "* another",
                "    - sub1",
                "    - sub2",
                "* last"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n<ul>\n<li>\nsub1\n</li>\n<li>\nsub2\n</li>\n</ul>\n</li>\n<li>\nlast\n</li>\n</ul>\n', #code->render)
        }

        it(`correctly parses nested ordered lists`) => {
            local(code) = markdown_listUnordered(#document, (:
                "* an item",
                "* another",
                "    0. sub1",
                "    0. sub2",
                "* last"
            ))
            expect('<ul>\n<li>\nan item\n</li>\n<li>\nanother\n<ol>\n<li>\nsub1\n</li>\n<li>\nsub2\n</li>\n</ol>\n</li>\n<li>\nlast\n</li>\n</ul>\n', #code->render)
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not an unordered list`) => {
            local(code) = markdown_listUnordered(#document, (:"    *"))
            expect((:"    *"), #code->leftover)
        }

        it(`returns an empty staticarray if all lines are part of unordered list`) => {
            local(code) = markdown_listUnordered(#document, (:
                "  - an item",
                "  - another",
                "",
                " - third"
            ))
            expect((:), #code->leftover)
        }

        it(`returns a staticarray without the unordered list lines`) => {
            local(code) = markdown_listUnordered(#document, (:
                "   - an item",
                "   - another",
                "",
                "here"
            ))
            expect((:"here"), #code->leftover)
        }
    }
}
