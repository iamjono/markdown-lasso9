[
/* =============================================================
Supports
	Setext-style headers
	atx headers
	code blocks (with &, <, > encoding to html entities)
	** & __ demark strong
	* demark em
	* & _ surrounded by spaces are protected.
	escaped backticks are protected
	text inline and surrounded by backticks is wrapped in <code>...</code>
	
TODO
	Links
	Images
============================================================= */

define markdown => type {
	data
		private source::string,
		private lines::array,
		private out::string
	public onCreate(src::string) => {
		#src->trim
		while(#src->endswith('\r\n')) => {
			#src->removeTrailing('\r\n')
			#src->trim
		}
		not #src->size ? return string
		.source = #src
		.decode
		return .out
	}
	private decode() => {
		.source->replace('\r\n','\|\\')
		.source->replace('\n','\|\\')
		.source->replace('\r','\|\\')
	
		.lines = .source->split('\|\\')
		.stdheaders
		.atxheaders
		.codeblock
		.out = .lines->join('\r\n')
		.protectSpecial
		.emphasis('**','<strong>','</strong>')
		.emphasis('__','<strong>','</strong>')
		.emphasis('*','<em>','</em>')
//		.emphasis('_','<em>','</em>') // removed so that underscores are able to be used. useful given prevalence in lasso code
		.emphasis('`','<code>','</code>')
		.deProtectSpecial
		.doParas
	}
	private stdheaders() => {
		while(
			.lines->first->beginswith('=') || 
			.lines->first->beginswith('-')
			) => {
			.lines->remove(1)
		}
		local(counter = 1, newlines = array)
		with line in .lines do => {
			if(#counter < .lines->size) => {
				if(.lines->get(#counter + 1)->beginswith('==')) => {
					#newlines->insert('<h1>'+#line+'</h1>')
					.lines->remove(#counter + 1)
				else(.lines->get(#counter + 1)->beginswith('--'))
					#newlines->insert('<h2>'+#line+'</h2>')
					.lines->remove(#counter + 1)
				else
					#newlines->insert(#line)
				}
				#counter++
			else
				// fixes "last line missing" issue
				#newlines->insert(#line)
			}
		}
		.lines = #newlines
	} //stdheaders
	
	private atxheaders() => {
		local(newlines = array)
		with line in .lines do => {
			local(linetype = 0)		
			#line->removeTrailing('#')
			if(#line->beginswith('###### ')) => {
				#line->removeLeading('######')
				#linetype = 6
			else(#line->beginswith('##### '))
				#line->removeLeading('##### ')
				#linetype = 5
			else(#line->beginswith('#### '))
				#line->removeLeading('#### ')
				#linetype = 4
			else(#line->beginswith('### '))
				#line->removeLeading('### ')
				#linetype = 3
			else(#line->beginswith('## '))
				#line->removeLeading('## ')
				#linetype = 2
			else(#line->beginswith('# '))
				#line->removeLeading('# ')
				#linetype = 1
			}
			#linetype > 0 ? 
				#newlines->insert('<h'+#linetype+'>'+#line+'</h'+#linetype+'>') |
				#newlines->insert(#line) 
		}
		.lines = #newlines
	}
	private codeblock() => {
		local(counter = 1, newlines = array, tabstate = false)
		with line in .lines do => {
		
			if(#counter <= .lines->size) => {
				if(#line->beginswith('    ') || #line->beginswith('\t')) => {
					// protect asterisks and underscores 
					#line->replace('**','|||||DASTERISK|||||')
					#line->replace('*','|||||ASTERISK|||||')
					#line->replace('__','|||||DUNDERSCORE|||||')
					#line->replace('_','|||||UNDERSCORE|||||')
					
					// convert ampersands and angle brackets into html entities
					#line->replace('&','&amp;')
					#line->replace('<','&lt;')
					#line->replace('>','&gt;')
					#tabstate == false ? 
						#newlines->insert('<pre><code>'+#line) |
						#newlines->insert(#line)
					#tabstate = true
					
					if(
						not .lines->get(#counter + 1)->beginswith('    ') && 
						not .lines->get(#counter + 1)->beginswith('\t')
					) => {
						#newlines->last->append('</code></pre>')
						#tabstate = false
					}
				else
					#newlines->insert(#line)
				}
				#counter++
			}
		}
		.lines = #newlines
	}
	private deProtectSpecial() => {
		.out->replace('|||||DASTERISK|||||','**')
		.out->replace('|||||ASTERISK|||||','*')
		.out->replace('|||||DUNDERSCORE|||||','__')
		.out->replace('|||||UNDERSCORE|||||','_')
		.out->replace('|||||BACKTICK|||||','`')
	}
	private protectSpecial() => {
		.out->replace(' * ',' |||||ASTERISK||||| ')
		.out->replace(' _ ',' |||||UNDERSCORE||||| ')
		.out->replace('\\*','|||||ASTERISK|||||')
		.out->replace('\\_','|||||UNDERSCORE|||||')
		.out->replace('\\`','|||||BACKTICK|||||')
	}
	private emphasis(term::string,whenon::string,whenoff::string) => {
		local(isOn = false, sarray = .out->split(#term), compile = #sarray->first)
		with s in #sarray
		skip 1
		do => {
			if(not #isOn) => { 
				#compile->append(#whenon+#s)
				#isOn = true
			else
				#compile->append(#whenoff+#s)
				#isOn = false
			}
		}
		#isOn ? #compile->append(#whenoff)
		.out = #compile
	}
	private doParas() => {
		.lines = .out->split('\r\n\r\n')
		local(newlines = string)
		with line in .lines do => {
			not #line->beginswith('<h') && not #line->beginswith('<pre') ?
				#newlines->append('<p>'+#line+'</p>') |
				#newlines->append(#line)
		}
		.out = #newlines
	}
}

]