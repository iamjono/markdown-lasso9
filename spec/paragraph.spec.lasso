local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + 'spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_paragraph) => {
    describe(`-> render`) => {
        it(`returns an empty string if the first line is empty`) => {
            local(code) = markdown_paragraph((:' \t'))
            expect('', #code->render)
        }

        it(`returns an html paragraph if passed one line`) => {
            local(code) = markdown_paragraph((:"A paragraph"))
            expect("<p>A paragraph</p>\n", #code->render)
        }

        it(`correctly parses multiple line paragraph`) => {
            local(code) = markdown_paragraph((:
                "Now is the time",
                "for all good men",
                "to come to the aid",
                "of their country."
            ))
            expect('<p>Now is the time\nfor all good men\nto come to the aid\nof their country.</p>\n',
                #code->render
            )
        }
    }

    describe(`-> leftover`) => {
        it(`returns the original array if not a paragraph`) => {
            local(code) = markdown_paragraph((:' \t'))
            expect((:' \t'), #code->leftover)
        }

        it(`returns an empty staticarray if all lines are part of a paragraph`) => {
            local(code) = markdown_paragraph((:
                "Now is the time",
                "for all good men",
                "to come to the aid",
                "of their country."
            ))
            expect((:), #code->leftover)
        }

        it(`returns a staticarray without the paragraph lines`) => {
            local(code) = markdown_paragraph((:"paragraph", "", "here"))

            expect((:"", "here"), #code->leftover)
        }
    }

    describe(`edge cases`) => {
        it(`stops the paragraph when runs into a blockquote`) => {
            local(code) = markdown_paragraph((:
                "This is all",
                "in one paragraph",
                "> Tom's quote here"
            ))
            expect("<p>This is all\nin one paragraph</p>\n", #code->render)
            expect((:"> Tom's quote here"), #code->leftover)
        }
    }
}