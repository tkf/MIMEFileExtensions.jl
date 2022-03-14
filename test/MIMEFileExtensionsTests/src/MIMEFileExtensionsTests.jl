module MIMEFileExtensionsTests

using Documenter
using MIMEFileExtensions
using Test

function test_list()
    dict = Dict(row.mime => row.fileexts for row in MIMEFileExtensions.list())
    @test ("txt", "log") ⊆ dict["text/plain"]
    @test ("jpeg", "jpg") ⊆ dict["image/jpeg"]
end

function test_fileexts_from_mime()
    @test ("txt", "log") ⊆ fileexts_from_mime("text/plain")
    @test ("jpeg", "jpg") ⊆ fileexts_from_mime("image/jpeg")
end

function test_mimes_from_fileext()
    @test ("text/plain",) ⊆ MIMEFileExtensions.mimes_from_fileext("txt")
    @test ("image/jpeg",) ⊆ MIMEFileExtensions.mimes_from_fileext("jpg")
end

function test_doctest()
    doctest(MIMEFileExtensions; manual = false)
end

end  # module MIMEFileExtensionsTests
