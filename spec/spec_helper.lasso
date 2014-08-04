local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')

with file in (:
    'markdown.lasso',
    'markdown_document.lasso',
    'markdown_hr.lasso',
    'markdown_codeblock.lasso',
    'markdown_html.lasso',
    'markdown_headerAtx.lasso',
    'markdown_headerSetext.lasso',
    'markdown_paragraph.lasso',
    'markdown_blockquote.lasso',
    'markdown_listOrdered.lasso',
    'markdown_listUnordered.lasso',
    'markdown_listItem.lasso'
)
do sourcefile(file(#path_here + '../' #file), -autoCollect=false)->invoke

var(_markdown_loaded) = true