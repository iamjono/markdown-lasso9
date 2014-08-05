local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')

define dir_import(d::dir, ext::staticarray=(:'lasso', 'inc')) => {
    with f in #d->eachFile
    where #ext->contains(#f->path->split('.')->last) 
    do file_import(#f)

    with f in #d->eachDir do dir_import(#f)
}
define file_import(f::file) => {
    sourcefile(#f, -autoCollect=false)->invoke
}

with path in (:
    'markdown.lasso',
    'markdown_reference.lasso',
    'parsers/'
)
do {
    #path->endsWith('/')
        ? dir_import(dir(#path_here + '../' #path))
        | file_import(file(#path_here + '../' #path))
}

var(_markdown_loaded) = true