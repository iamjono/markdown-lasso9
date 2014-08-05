define markdown => type {
    data 
        private source,
        private sourceFile

    public onCreate(source::string) => {
        .source = #source
    }
    public onCreate(source::file) => {
        .sourceFile = #source
    }

    public source => (.sourceFile? .sourceFile->readString | .`source`)

    public source=(rhs::file) => {
        .sourceFile = #rhs
        return #rhs
    }
    public source=(rhs::string) => {
        .`source`   = #rhs
        .sourceFile = void
        return #rhs
    }

    public render => markdown_document(.source)->render
}
