local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown_document) => {
    describe(`creator method`) => {
        it(`correctly strips out standard reference for links / images`) => {
            local(doc) = markdown_document(`[id]: /site/path`)
            expect((:), #doc->lines)
        }
        it(`correctly strips out reference for links / images with title on same line`) => {
            local(doc) = markdown_document(`[id]: /site/path "Title"`)
            expect((:), #doc->lines)

            local(doc) = markdown_document(`[id]: /site/path 'Title'`)
            expect((:), #doc->lines)

            local(doc) = markdown_document(`[id]: /site/path (Title)`)
            expect((:), #doc->lines)
        }

        it(`correctly strips out reference for links / images with title on next line`) => {
            local(doc) = markdown_document(`[id]: /site/path` + "\n" + `  "Title"`)
            expect((:), #doc->lines)
        }
    }

    describe(`-> references`) => {
        local(doc) = markdown_document(`[id]: /site/path "My Title"` + "\n[the second]: http://example.com")

        it(`returns a map of markdown_reference's`) => {
            local(refs) = #doc->references
            expect(::map, #refs->type)

            with elm in #refs do expect(::markdown_reference, #elm->type)
        }

        it(`correctly sets up the map and the values`) => {
            local(item) = #refs->find(`id`)
            expect(`/site/path`, #item->url)
            expect(`My Title`  , #item->title)

            local(item) = #refs->find(`the second`)
            expect(`http://example.com`, #item->url)
            expect(``, #item->title)
        }
    }
}