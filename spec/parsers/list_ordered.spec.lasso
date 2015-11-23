local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

local(document) = markdown_document(``)

describe(::markdown_listOrdered) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match an ordered list`) => {
            local(code) = markdown_listOrdered(#document, (:"    1."))
            expect('', #code->render)

            local(code) = markdown_listOrdered(#document, (:"1.miss space"))
            expect('', #code->render)
        }

        it(`returns an html ul if passed lines matching markdown ordered list`) => {
            local(code) = markdown_listOrdered(#document, (:"2. nice"))
            expect('<ol>\n<li>\nnice\n</li>\n</ol>\n', #code->render)
        }

        it(`correctly parses multiple list items`) => {
            local(code) = markdown_listOrdered(#document, (:
                " 1. an item",
                " 1. another"
            ))
            expect('<ol>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ol>\n', #code->render)

            local(code) = markdown_listOrdered(#document, (:
                "1. an item",
                "1. another"
            ))
            expect('<ol>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ol>\n', #code->render)

            local(code) = markdown_listOrdered(#document, (:
                "   1. an item",
                "   1. another"
            ))
            expect('<ol>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ol>\n', #code->render)
        }

        it(`correctly parses multiple list items with blank lines`) => {
            local(code) = markdown_listOrdered(#document, (:
                "  1. an item",
                "",
                "",
                "  1. another"
            ))
            expect('<ol>\n<li>\nan item\n</li>\n<li>\nanother\n</li>\n</ol>\n', #code->render)
        }

        it(`correctly parses nested ordered lists`) => {
            local(code) = markdown_listOrdered(#document, (:
                "1. an item",
                "1. another",
                "\t1. sub1",
                "\t1. sub2",
                "1. last"
            ))
            expect('<ol>\n<li>\nan item\n</li>\n<li>\nanother\n<ol>\n<li>\nsub1\n</li>\n<li>\nsub2\n</li>\n</ol>\n</li>\n<li>\nlast\n</li>\n</ol>\n', #code->render)
        }

        it(`correctly parses nested unordered lists`) => {
            local(code) = markdown_listOrdered(#document, (:
                "1. an item",
                "1. another",
                "    * sub1",
                "    * sub2",
                "1. last"
            ))
            expect('<ol>\n<li>\nan item\n</li>\n<li>\nanother\n<ul>\n<li>\nsub1\n</li>\n<li>\nsub2\n</li>\n</ul>\n</li>\n<li>\nlast\n</li>\n</ol>\n', #code->render)
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not an ordered list`) => {
            local(code) = markdown_listOrdered(#document, (:"    1."))
            expect((:"    1."), #code->leftover)
        }

        it(`returns an empty staticarray if all lines are part of ordered list`) => {
            local(code) = markdown_listOrdered(#document, (:
                "  1. an item",
                "  1. another",
                "",
                " 1. third"
            ))
            expect((:), #code->leftover)
        }

        it(`returns a staticarray without the ordered list lines`) => {
            local(code) = markdown_listOrdered(#document, (:
                "   1. an item",
                "   1. another",
                "",
                "here"
            ))
            expect((:"here"), #code->leftover)
        }
    }
}