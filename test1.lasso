[
//	not lasso_tagexists('markdown') ? 
		include('markdown.lasso')

	// tests
	local(f = file('test1.txt'))
	#f->doWithClose => {
		local(test1 = #f->readString)
    }
	
	markdown(#test1)
]