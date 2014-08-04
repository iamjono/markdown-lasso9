define markdown_html => type {
    data
        private render,
        private leftover

    public onCreate(lines::staticarray) => {
        .render = ''

        local(line1)   = #lines->first
        local(reStart) = regExp(-input=#line1, -find=`^<([^\s>]+).*?>.*$`)
        if(not #reStart->matches) => {
            .leftover = #lines
            return
        }

        local(tag_end) = '</' + #reStart->matchString(1) + '>'
        local(end)     = 0

        while(++#end <= #lines->size) => {
            local(line) = #lines->get(#end)

            if(#line->asCopy->trim& == '') => {
                .render->append("\n")
                loop_continue
            }

            .render->append(#line + "\n")

            #line->asCopy->trim& == #tag_end
                ? loop_abort
        }

        .leftover = #lines->sub(#end+1)
    }


    public
        render   => .`render`,
        leftover => .`leftover`
}