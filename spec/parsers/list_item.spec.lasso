local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

local(document) = markdown_document(``)

describe(::markdown_listItem) => {
    describe(`creator method`) => {
        it(`fails if not passed either -ordered or -unordered`) => {
            expect->errorCode(error_code_invalidParameter) => {
                markdown_listItem(#document, (:"* "))
            }
        }
        it(`fails if passed both -ordered or -unordered`) => {
            expect->errorCode(error_code_invalidParameter) => {
                markdown_listItem(#document, (:"* "), -ordered, -unordered)
            }
        }
    }

    describe(` -> render`) => {
        it(`returns an empty string if the first line doesn't match a list item`) => {
            local(item) = markdown_listItem(#document, (:"*done"), -unordered)
            expect('', #item->render)
        }

        it(`returns an empty string if the first line isn't the specified type of list item`) => {
            local(item) = markdown_listItem(#document, (:"* done"), -ordered)
            expect('', #item->render)

            local(item) = markdown_listItem(#document, (:"1. done"), -unordered)
            expect('', #item->render)
        }

        it(`returns a single list item if that's all there is`) => {
            local(item) = markdown_listItem(#document, (:"* item"), -unordered)
            expect('<li>\nitem\n</li>\n', #item->render)

            local(item) = markdown_listItem(#document, (:"+ item"), -unordered)
            expect('<li>\nitem\n</li>\n', #item->render)

            local(item) = markdown_listItem(#document, (:"  - item"), -unordered)
            expect('<li>\nitem\n</li>\n', #item->render)

            local(item) = markdown_listItem(#document, (:"1. item"), -ordered)
            expect('<li>\nitem\n</li>\n', #item->render)
        }

        it('deals with multiple unindented lines correctly') => {
            local(item) = markdown_listItem(#document, (:"- This is in", "three different", "lines."), -unordered)
            expect('<li>\nThis is in\nthree different\nlines.\n</li>\n', #item->render)

            local(item) = markdown_listItem(#document, (:"1. This is in", "three different", "lines."), -ordered)
            expect('<li>\nThis is in\nthree different\nlines.\n</li>\n', #item->render)
        }

        it('deals with multiple indented lines correctly') => {
            local(item) = markdown_listItem(#document, (:"- This is in", "\tthree different", "\tlines."), -unordered)
            expect('<li>\nThis is in\nthree different\nlines.\n</li>\n', #item->render)

            local(item) = markdown_listItem(#document, (:"1. This is in", "    three different", "    lines."), -ordered)
            expect('<li>\nThis is in\nthree different\nlines.\n</li>\n', #item->render)
        }

        it(`stops when next list item is directly after it`) => {
            local(item) = markdown_listItem(#document, (:"- item", "- another"), -unordered)
            expect('<li>\nitem\n</li>\n', #item->render)
        }
        it(`stops when next list item is separated by an empty line`) => {
            local(item) = markdown_listItem(#document, (:"- item", " ", "- another"), -unordered)
            expect('<li>\nitem\n</li>\n', #item->render)
        }
    }

    describe(` -> leftover`) => {
        it(`returns the staticarray if the first line doesn't match a list item`) => {
            local(item) = markdown_listItem(#document, (:"*done"), -unordered)
            expect((:"*done"), #item->leftover)
        }

        it(`returns the staticarray if the first line isn't the specified type of list item`) => {
            local(item) = markdown_listItem(#document, (:"* done"), -ordered)
            expect((:"* done"), #item->leftover)

            local(item) = markdown_listItem(#document, (:"1. done"), -unordered)
            expect((:"1. done"), #item->leftover)
        }

        it(`returns an empty array if all the lines are a list item`) => {
            local(item) = markdown_listItem(#document, (:"- This is in", "three different", "    lines."), -unordered)
            expect((:), #item->leftover)
        }

        it(`returns the array minus the first list item if list items not speparated by space`) => {
            local(item) = markdown_listItem(#document, (:"- item", "- another"), -unordered)
            expect((:"- another"), #item->leftover)
        }

        it(`returns the array minus the first list item if list items are speparated by space`) => {
            local(item) = markdown_listItem(#document, (:"- item","\t", "- another"), -unordered)
            expect((:"- another"), #item->leftover)
        }
    }

    context(`nested block elements`) => {
        it(`properly parses nested paragraph`) => {
            local(item) = markdown_listItem(#document, (:"- line 1", "", "\tnested p"), -unordered)
            expect("<li>\nline 1\n<p>nested p</p>\n</li>\n", #item->render)
        }

        it(`properly parses nested lists`) => {
            local(item) = markdown_listItem(#document, (:"- header line","\t+ Sub list"), -unordered)
            expect("<li>\nheader line\n<ul>\n<li>\nSub list\n</li>\n</ul>\n</li>\n", #item->render)
        }
    }
}