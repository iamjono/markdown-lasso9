local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')

sourcefile(file(#path_here + '../spec/spec_helper.lasso'), -autoCollect=false)->invoke

    // tests
    markdown(file(#path_here + 'syntax.text'))->render