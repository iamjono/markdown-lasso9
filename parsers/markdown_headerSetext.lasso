define markdown_headerSetext => type {
    data
        private render,
        private leftover

    public onCreate(lines::staticarray) => {
        local(line1) = #lines->first->asCopy
        local(line2) = #lines->second

        if(not #line1 or not #line2 or not regExp(-input=#line2, -find=`^(=+|-+)\s*$`)->matches) => {
            .render   = ''
            .leftover = #lines
            return
        }

        local(level) = (#line2->sub(1,1) == '-' ? 2 | 1)

        .render   = '<h' + #level + '>' + #line1->trim& + '</h' + #level + '>\n'
        .leftover = #lines->sub(3)
    }


    public
        render   => .`render`,
        leftover => .`leftover`
}