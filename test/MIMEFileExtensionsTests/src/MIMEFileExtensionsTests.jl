module MIMEFileExtensionsTests

using Documenter
using MIMEFileExtensions
using Test

macro s_str(x::AbstractString)
    QuoteNode(Symbol(x))
end

function test_list()
    dict = Dict(row.mime => row.fileexts for row in MIMEFileExtensions.list())
    @test [s"txt", s"log"] ⊆ dict[s"text/plain"]
    @test [s"jpeg", s"jpg"] ⊆ dict[s"image/jpeg"]
end

function test_fileexts_from_mime()
    @test [s"txt", s"log"] ⊆ fileexts_from_mime(s"text/plain")
    @test [s"jpeg", s"jpg"] ⊆ fileexts_from_mime("image/jpeg")
    @test [s"png"] ⊆ fileexts_from_mime(MIME"image/png"())
end

function test_mimes_from_fileext()
    @test [s"text/plain"] ⊆ MIMEFileExtensions.mimes_from_fileext(s"txt")
    @test [s"image/jpeg"] ⊆ MIMEFileExtensions.mimes_from_fileext("jpg")
end

function test_doctest()
    doctest(MIMEFileExtensions; manual = false)
end

end  # module MIMEFileExtensionsTests
