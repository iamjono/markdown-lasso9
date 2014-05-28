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
	unordered lists (lines starting with -)
	hr
	
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
		local(newsrc = #src->asCopy) // force it to NOT be modified even in the original parent
	
		//#src->trim
		while(#newsrc->beginswith('\r\n')) => {
			#newsrc->removeLeading('\r\n')
			//#src->trim
		}
		while(#newsrc->endswith('\r\n')) => {
			#newsrc->removeTrailing('\r\n')
			//#src->trim
		}
		not #newsrc->size ? return string
		.source = #newsrc
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
		.doHr
		.ulists
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
					
					// replace tabs with 4 spaces
					#line->replace('\t','    ')
					
					// remove first 4 spaces to remove first "indent"
					#line->remove(1,4)
					
					// convert ampersands and angle brackets into html entities
					#line->replace('&','&amp;')
					#line->replace('<','&lt;')
					#line->replace('>','&gt;')
					#tabstate == false ? 
						#newlines->insert('<pre><code>'+#line) |
						#newlines->insert(#line)
					#tabstate = true
					protect => {
						handle_error => {
							#newlines->last->append('</code></pre>')
							#tabstate = false
						}
						if(
							not .lines->get(#counter + 1)->beginswith('    ') && 
							not .lines->get(#counter + 1)->beginswith('\t')
						) => {
							#newlines->last->append('</code></pre>')
							#tabstate = false
						}
					}
				else
					#newlines->insert(#line)
				}
				#counter++
			}
		}
		.lines = #newlines
	}
	private ulists() => {
		local(counter = 1, newlines = array, ulstate = false)
		with line in .lines do => {
			if(#counter <= .lines->size) => {
				if(#line->beginswith('-') ) => {
					#line = #line->sub(2)
					#ulstate == false ? 
						#newlines->insert('<ul><li>'+#line+'</li>') |
						#newlines->insert('<li>'+#line+'</li>')
					#ulstate = true
					protect => {
						handle_error => {
							#newlines->last->append('</ul>')
							#ulstate = false
						}
						// if not end of doc check for open ul
						if(not .lines->get(#counter + 1)->beginswith('-')) => {
							#newlines->last->append('</ul>')
							#ulstate = false
						}
					}
				else
					#newlines->insert(#line)
				}
				#counter++
			}
		}
		.lines = #newlines	}
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
	private doHr() => {
		local(newlines = array)
		with line in .lines do => {
			if(
				#line->beginswith('* * *') || 
				#line->beginswith('***') || 
				#line->beginswith('- - -') || 
				#line->beginswith('---') || 
				#line->beginswith('_ _ _') || 
				#line->beginswith('___')
			) => {
				#line = '<hr />'
			}
			#newlines->insert(#line)
		}
		.lines = #newlines
	}
}

]
