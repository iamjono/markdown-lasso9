local(path_here) = currentCapture->callsite_file->stripLastComponent
not #path_here->beginsWith('/')? #path_here = io_file_getcwd + '/' + #path_here
not #path_here->endsWith('/')  ? #path_here->append('/')
not var_defined('_markdown_loaded')
    ? sourcefile(file(#path_here + 'spec_helper.lasso'), -autoCollect=false)->invoke

describe(::markdown) => {
    describe(` -> source`) => {
        local(src)       = "Relevant Rhino"
        local(test_file) = file(`//tmp/` + lasso_uniqueID + '.md')
        beforeAll => {
            #test_file->doWithClose => {
                #1->writeString(#src)
            }
        }
        afterAll => {
            #test_file->delete
        }
        it(`returns the contents of the source string`) => {
            local(md)  = markdown(#src)

            expect(#src, #md->source)
        }

        it(`returns the contents of the source file`) => {
            local(md) = markdown(#test_file)

            expect(#src, #md->source)
        }

        it(`returns the new contents of the source file if the file on disk changes`) => {
            local(md) = markdown(#test_file)

            #test_file->doWithClose => {
                #test_file->openAppend&writeString(" Runs")
            }

            expect(#src + " Runs", #md->source)
        }
    }

    describe(` -> source=`) => {
        local(test_file1) = file(`//tmp/` + lasso_uniqueID + `.md`)
        local(test_file2) = file(`//tmp/` + lasso_uniqueID + `.md`)
        beforeAll => {
            #test_file1->doWithClose => {
                #test_file1->openTruncate&writeString("Daring")
            }
            #test_file2->doWithClose => {
                #test_file2->openTruncate&writeString("Rescue")
            }
        }
        afterAll =>{
            #test_file1->delete
            #test_file2->delete
        }

        context('passed a file object') => {
            it(`sets the source to the new file object even if original had a string`) => {
                local(md) = markdown("Fabulous")

                #md->source = #test_file1

                expect("Daring", #md->source)
            }
            it(`sets the source to the new file object`) => {
                local(md) = markdown(#test_file1)

                #md->source = #test_file2

                expect("Rescue", #md->source)
            }
        }
        context(`padded a string`) => {
            it(`sets the source to the string even if original had a file`) => {
                local(md) = markdown(#test_file1)

                #md->source = "Fabulous"

                expect("Fabulous", #md->source)
            }
            it(`sets the source to the new string`) => {
                local(md) = markdown("Fabulous")

                #md->source = "Track"

                expect("Track", #md->source)
            }
        }
    }
}

//markdown(file(`/file/path`)).render
//markdown(file(`/file/path`)).render(`/file/path`)
//
//markdown("string code").render
//markdown("string code").render(`/file/path`)

