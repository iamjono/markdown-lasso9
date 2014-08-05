local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_headerAtx) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match a markdown atx header`) => {
            local(header) = markdown_headerAtx((:"not correct"))
            expect('', #header->render)
        }
        it(`returns the appropriate header tag if passed lines matching atx header`) => {
            local(header) = markdown_headerAtx((:"#First"))
            expect('<h1>First</h1>\n', #header->render)

            local(header) = markdown_headerAtx((:"## Second"))
            expect('<h2>Second</h2>\n', #header->render)

            local(header) = markdown_headerAtx((:"### Third"))
            expect('<h3>Third</h3>\n', #header->render)

            local(header) = markdown_headerAtx((:"####Fourth"))
            expect('<h4>Fourth</h4>\n', #header->render)

            local(header) = markdown_headerAtx((:"#####Fifth"))
            expect('<h5>Fifth</h5>\n', #header->render)

            local(header) = markdown_headerAtx((:"###### Sixth"))
            expect('<h6>Sixth</h6>\n', #header->render)
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not a markdown header`) => {
            local(header) = markdown_headerAtx((:"not correct"))
            expect((:"not correct"), #header->leftover)
        }

        it(`returns an empty staticarray if only one line and a markdown header`) => {
            local(header) = markdown_headerAtx((:"# Done"))
            expect((:), #header->leftover)
        }

        it(`returns a staticarray that has the first element removed`) => {
            local(header) = markdown_headerAtx((:"##Am Header", "", "Next"))
            expect((:"", "Next"), #header->leftover)
        }
    }
}