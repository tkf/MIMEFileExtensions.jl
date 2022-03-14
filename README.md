# MIMEFileExtensions

Lookup MIME types from a file extension and vice versa.

This is based on the mapping in Apache HTTP server project:
https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types

## Example

```julia
julia> using MIMEFileExtensions

julia> fileexts_from_mime("image/jpeg")
("jpeg", "jpg", "jpe")

julia> mimes_from_fileext("txt")
("text/plain",)
```
