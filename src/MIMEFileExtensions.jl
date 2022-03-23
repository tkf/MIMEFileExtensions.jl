baremodule MIMEFileExtensions

export fileexts_from_mime, mimes_from_fileext

function fileexts_from_mime end
function mimes_from_fileext end

function list end

"""
    fileexts_from_mime(mime::Union{Symbol,AbstractString,MIME}) -> fileexts::Vector{Symbol}

List file extentions `fileexts` known to be used for `mime`.  Return an empty tuple if not
found.

# Example

```jldoctest
julia> using MIMEFileExtensions

julia> fileexts_from_mime("image/jpeg")
3-element Vector{Symbol}:
 :jpeg
 :jpg
 :jpe

julia> fileexts_from_mime(MIME"image/png"())
1-element Vector{Symbol}:
 :png
```
"""
fileexts_from_mime

"""
    mimes_from_fileext(fileext::Union{Symbol,AbstractString}) -> mimes::Vector{Symbol}

List MIMEs `mimes` known to be used for file extention `fileext`.  Return an empty tuple if
not found.

# Example

```jldoctest
julia> using MIMEFileExtensions

julia> mimes_from_fileext("txt")
1-element Vector{Symbol}:
 Symbol("text/plain")
```
"""
mimes_from_fileext

"""
    MIMEFileExtensions.list() -> table

Return a `table`` with columns `mime::Symbol` and `fileexts::Vector{Symbol}`.

# Example

```jldoctest
julia> using MIMEFileExtensions

julia> only(
           r.mime => r.fileexts for r in MIMEFileExtensions.list()
           if r.mime == Symbol("image/jpeg")
       )
Symbol("image/jpeg") => [:jpeg, :jpg, :jpe]
```
"""
list

module Internal

using ..MIMEFileExtensions: MIMEFileExtensions

const Syms = Vector{Symbol}
const Row = NamedTuple{(:mime, :fileexts),Tuple{Symbol,Syms}}
const TABLE = Row[]

row(mime, fileexts) = Row((mime, fileexts))

datapath() = joinpath(@__DIR__, "../data/mime.types")

function load!(table = empty!(TABLE))
    lines = readlines(datapath())
    headerline = nothing
    for i in eachindex(lines)
        if startswith(lines[i], "# MIME type (lowercased)")
            headerline = i
            break
        end
    end
    if headerline === nothing
        error("header not found")
    end
    let separator = lines[headerline+1]
        if !startswith(separator, "# ===")
            error("header separator not found: ", separator)
        end
    end
    for i in headerline+2:lastindex(lines)
        ln = lines[i]
        m = match(
            r"""
            ^
            (?<comment>\#\s+)?
            (?<mime>[a-z0-9/.+\-]+)
            (?<ext>\s*[A-Za-z0-9]+.*)?
            $
            """x,
            ln,
        )
        if m !== nothing
            mime = Symbol(m["mime"])
            fileexts = map(Symbol, split(something(m["ext"], "")))
            r = row(mime, fileexts)
            push!(table, r)
        else
            error("invalid table row: ", ln)
        end
    end
    return table
end

const FILEEXTS_FROM_MIME = Dict{Symbol,Syms}()
const MIMES_FROM_FILEEXT = Dict{Symbol,Syms}()

function index_fileexts_from_mime!(dict = empty!(FILEEXTS_FROM_MIME), table = TABLE)
    for row in table
        mime = row.mime
        fileexts = row.fileexts
        isempty(fileexts) && continue
        dict[mime] = fileexts
    end
    return dict
end

function index_mimes_from_fileext!(dict = empty!(MIMES_FROM_FILEEXT), table = TABLE)
    for row in table
        mime = row.mime
        fileexts = row.fileexts
        for ext in fileexts
            push!(get!(() -> Symbol[], dict, ext), mime)
        end
    end
    return dict
end

# TODO: thread-safe lazy loading?
MIMEFileExtensions.list() = TABLE

MIMEFileExtensions.fileexts_from_mime(mime::Symbol) =
    get(FILEEXTS_FROM_MIME, mime, Symbol[])
MIMEFileExtensions.fileexts_from_mime(mime::AbstractString) =
    MIMEFileExtensions.fileexts_from_mime(Symbol(mime))
MIMEFileExtensions.fileexts_from_mime(@nospecialize(mime::MIME)) =
    MIMEFileExtensions.fileexts_from_mime(Symbol(mime))

MIMEFileExtensions.mimes_from_fileext(ext::Symbol) = get(MIMES_FROM_FILEEXT, ext, Symbol[])
MIMEFileExtensions.mimes_from_fileext(ext::AbstractString) =
    MIMEFileExtensions.mimes_from_fileext(Symbol(ext))

# Bundle `TABLE` in precompile cache for sysimage-compatibility:
load!()
include_dependency(datapath())

function __init__()
    index_fileexts_from_mime!()
    index_mimes_from_fileext!()
    return
end

@doc let path = joinpath(dirname(@__DIR__), "README.md")
    include_dependency(path)
    replace(read(path, String), r"^```julia"m => "```jldoctest README")
end MIMEFileExtensions

end  # module Internal

end  # baremodule MIMEFileExtensions
