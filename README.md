# MIMEFileExtensions

Lookup MIME types from a file extension and vice versa.

This is based on the mapping in Apache HTTP server project:
https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types

## Example

```julia
julia> using MIMEFileExtensions

julia> fileexts_from_mime("image/jpeg")
3-element Vector{Symbol}:
 :jpeg
 :jpg
 :jpe

julia> mimes_from_fileext("txt")
1-element Vector{Symbol}:
 Symbol("text/plain")
```

## See also

* https://github.com/fonsp/MIMEs.jl: Similar package that is based on a more comprehensive
  database.
* https://github.com/JuliaIO/FileType.jl: File type (including MIME) detection based also on
  the file content.
