local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_blockquote) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match a blockquote`) => {
            local(code) = markdown_blockquote((:' > oops'))
            expect('', #code->render)
        }
        it(`returns an html blockquote if passed lines matching markdown blockquote`) => {
            local(code) = markdown_blockquote((:"> potent potables"))
            expect("<blockquote>\n<p>potent potables</p>\n</blockquote>\n", #code->render)
        }
        it(`correctly parses multiple blockquote lines`) => {
            local(code) = markdown_blockquote((:
                "> First line",
                "> Second line",
                "> Third line"
            ))
            expect("<blockquote>\n<p>First line\nSecond line\nThird line</p>\n</blockquote>\n", #code->render)

            local(code) = markdown_blockquote((:
                "> First line",
                "Second line",
                "Third line"
            ))
            expect("<blockquote>\n<p>First line\nSecond line\nThird line</p>\n</blockquote>\n", #code->render)
        }

        it(`correctly parses multiple blockquote lines with blank lines`) => {
            local(code) = markdown_blockquote((:
                "> First line",
                "> ",
                ">",
                "> Second line",
                ">",
                "> Third line"
            ))
            expect("<blockquote>\n<p>First line</p>\n<p>Second line</p>\n<p>Third line</p>\n</blockquote>\n", #code->render)
        }

        it(`correctly parses nested blockquote lines`) => {
            local(code) = markdown_blockquote((:
                "> First line",
                "> > Second line",
                ">",
                "> Third line"
            ))
            expect("<blockquote>\n<p>First line</p>\n<blockquote>\n<p>Second line</p>\n</blockquote>\n<p>Third line</p>\n</blockquote>\n", #code->render)
        }

        it(`correctly parses nested headers`) => {
            local(code) = markdown_blockquote((:
                "> First",
                "> =====",
                "> ### Third"
            ))
            expect('<blockquote>\n<h1>First</h1>\n<h3>Third</h3>\n</blockquote>\n', #code->render)
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not a blockquote`) => {
            local(code) = markdown_blockquote((:' > oops'))
            expect((:' > oops'), #code->leftover)
        }

        it(`returns an empty staticarray if all lines are blockquotes`) => {
            local(code) = markdown_blockquote((:'> quoted'))
            expect((:), #code->leftover)
        }

        it(`returns a staticarray without the blockquote lines`) => {
            local(code) = markdown_blockquote((:'> quoted','more', '> even more', '', 'done'))
            expect((:'done'), #code->leftover)
        }
    }
}