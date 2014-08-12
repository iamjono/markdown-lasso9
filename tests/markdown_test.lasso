local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')

sourcefile(file(#path_here + '../spec/spec_helper.lasso'), -autoCollect=false)->invoke


local(test_names) = (:
	`Amps and angle encoding`,
	`Auto links`,
	`Backslash escapes`,
	`Blockquotes with code blocks`,
	`Hard-wrapped paragraphs with list-like lines`,
	`Horizontal rules`,
	`Inline HTML (Advanced)`,
	`Inline HTML (Simple)`,
	`Inline HTML comments`,
	`Links, inline style`,
	`Links, reference style`,
	`Literal quotes in titles`,
	`Markdown Documentation - Basics`,
	`Markdown Documentation - Syntax`,
	`Nested blockquotes`,
	`Ordered and unordered lists`,
	`Strong and em together`,
	`Tabs`,
	`Tidyness`
)

with name in #test_names
let test_file = file(#path_here + 'markdown_tests/' + #name + ".text")
let canon_out = file(#path_here + 'markdown_tests/' + #name + ".html")->readString
do {
	stdoutnl(#name)

	#canon_out != markdown(#test_file)->render
		? stdoutnl('\tFAILED')
		| stdoutnl('\tPASSED')
}