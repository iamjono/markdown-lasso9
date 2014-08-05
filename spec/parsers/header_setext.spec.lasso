local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_headerSetext) => {
    describe(`-> render`) => {
        it(`returns an empty string if only one line`) => {
            local(header) = markdown_headerSetext((:"not correct"))
            expect('', #header->render)
        }
        
        it(`returns an empty string if the second line isn't markup for setext header`) => {
            local(header) = markdown_headerSetext((:"not correct", "g"))
            expect('', #header->render)
        }

        it(`returns the appropriate header tag if passed lines matching a setext header`) => {
            local(header) = markdown_headerSetext((:"First", "="))
            expect('<h1>First</h1>\n', #header->render)

            local(header) = markdown_headerSetext((:"Second", "-------"))
            expect('<h2>Second</h2>\n', #header->render)
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not a markdown header`) => {
            local(header) = markdown_headerSetext((:"not correct", "0"))
            expect((:"not correct", "0"), #header->leftover)
        }

        it(`returns an empty staticarray if only a markdown header`) => {
            local(header) = markdown_headerSetext((:"Done", "======"))
            expect((:), #header->leftover)
        }

        it(`returns a staticarray that has the first two element removed`) => {
            local(header) = markdown_headerSetext((:"A Header", "----", "Next"))
            expect((:"Next"), #header->leftover)
        }
    }
}