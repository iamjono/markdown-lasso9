local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + 'spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_hr) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line doesn't match a markdown HR`) => {
            local(hr) = markdown_hr((:"not correct"))
            expect('', #hr->render)
        }
        it(`returns an hr tag if passed lines match markdown HR`) => {
            local(hr) = markdown_hr((:"- - -"))
            expect('<hr />', #hr->render)

            local(hr) = markdown_hr((:"***"))
            expect('<hr />', #hr->render)

            local(hr) = markdown_hr((:"_ _    _"))
            expect('<hr />', #hr->render)
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not a markdown hr`) => {
            local(hr) = markdown_hr((:"not correct"))
            expect((:"not correct"), #hr->leftover)
        }

        it(`returns an empty staticarray if only one line and a markdown hr`) => {
            local(hr) = markdown_hr((:"* * *"))
            expect((:), #hr->leftover)
        }

        it(`returns a staticarray that has the first element removed`) => {
            local(hr) = markdown_hr((:"---------", "", "Next"))
            expect((:"", "Next"), #hr->leftover)
        }
    }
}