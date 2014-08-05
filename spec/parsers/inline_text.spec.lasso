local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + '../spec_helper.lasso'), -autoCollect=false)->invoke

local(document) = markdown_document(``)

// TODO: figure out how to test that I'm escaping - and * when they are just surrounded by space
// or when they're in an img or link tag or that I'm escaping everything in <code></code> spans
describe(::markdown_inlineText) => {
    describe(`-> render`) => {
        it(`correctly supports inline code spans`) => {
            local(code) = markdown_inlineText(#document, (:"`code`"))
            expect('<code>code</code>', #code->render)
        }

        it(`correctly allows for backticks in inline code spans with multiple backticks delimiter`) => {
            local(code) = markdown_inlineText(#document, (:"`` `code` ``"))
            expect('<code>`code`</code>', #code->render)
        }

        it(`correctly parses inline img markup without title`) => {
            local(code) = markdown_inlineText(#document, (:`![Alt text](/path/to/img.jpg)`))
            expect('<img src="/path/to/img.jpg" alt="Alt text" />', #code->render)
        }

        it(`correctly parses inline img markup with title`) => {
            local(code) = markdown_inlineText(#document, (:`![Alt text](/path/to/img.jpg "My Title")`))
            expect('<img src="/path/to/img.jpg" alt="Alt text" title="My Title" />', #code->render)
        }

        it(`correctly parses inline anchor markup without title`) => {
            local(code) = markdown_inlineText(#document, (:`[an example](http://example.com)`))
            expect('<a href="http://example.com">an example</a>', #code->render)
        }

        it(`correctly parses inline anchor markup with title`) => {
            local(code) = markdown_inlineText(#document, (:`[an example](http://example.com "My Title")`))
            expect('<a href="http://example.com" title="My Title">an example</a>', #code->render)
        }

        it(`correctly renders asterix italics`) => {
            local(code) = markdown_inlineText(#document, (:"*emphasis!*"))
            expect('<em>emphasis!</em>', #code->render)
        }

        it(`correctly renders asterix bold`) => {
            local(code) = markdown_inlineText(#document, (:"**bold**"))
            expect('<strong>bold</strong>', #code->render)
        }

        it(`correctly renders underscore italics`) => {
            local(code) = markdown_inlineText(#document, (:"_italic_"))
            expect('<em>italic</em>', #code->render)
        }

        it(`correctly renders underscore bold`) => {
            local(code) = markdown_inlineText(#document, (:"__bold__"))
            expect('<strong>bold</strong>', #code->render)
        }

        it(`correctly encodes ampersands`) => {
            local(code) = markdown_inlineText(#document, (:"&"))
            expect('&amp;', #code->render)
        }
        it(`correctly encodes less thans`) => {
            local(code) = markdown_inlineText(#document, (:"<"))
            expect('&lt;', #code->render)
        }

        it(`correctly puts a <br /> tag in if a line ends with 2 spaces and a new line`) => {
            local(code) = markdown_inlineText(#document, (:"food  ", ""))
            expect("food<br />\n", #code->render)
        }

        it(`correctly unescapes escaped characters`) => {
            local(code) = markdown_inlineText(#document, (:`\\`))
            expect(`\`, #code->render)
        }

        it(`correctly replaces image references`) => {
            local(doc)  = markdown_document('[id]: path/to/img.jpg "My Title"')
            local(code) = markdown_inlineText(#doc, (:"![Alt Text][id]"))

            expect(`<img src="path/to/img.jpg" alt="Alt Text" title="My Title" />`, #code->render)
        }

        it(`leaves image references alone that have no matching reference`) => {
            local(doc)  = markdown_document(``)
            local(code) = markdown_inlineText(#doc, (:"![Alt Text][id]"))

            expect("![Alt Text][id]", #code->render)
        }

        it(`correctly replaces link references`) => {
            local(doc)  = markdown_document('[id]: http://www.example.com "My Title"')
            local(code) = markdown_inlineText(#doc, (:"[link text][id]"))

            expect('<a href="http://www.example.com" title="My Title">link text</a>', #code->render)
        }
        
        it(`leaves link references alone that have no matching reference`) => {
            local(doc)  = markdown_document(``)
            local(code) = markdown_inlineText(#doc, (:"[link text][id]"))

            expect("[link text][id]", #code->render)
        }

        it(`allows for implicit IDs using link text - the text capitalization is preserved while comparing the ID case insensitively`) => {
            local(doc)  = markdown_document(`[daring fireball]: http://daringfireball.net`)
            local(code) = markdown_inlineText(#doc, (:"[Daring Fireball][]"))

            expect('<a href="http://daringfireball.net">Daring Fireball</a>', #code->render)
        }
    }
}