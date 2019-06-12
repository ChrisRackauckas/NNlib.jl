using BinaryProvider

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libnnpack"], :libnnpack),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaPackaging/Yggdrasil/releases/download/NNPACK-v2018.06.22-0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/NNPACK.v2018.6.22.aarch64-linux-gnu.tar.gz", "e0c6e21ba4c47acfd5a3d3e3510e8786474080f654338f4583b88860296c1437"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/NNPACK.v2018.6.22.i686-linux-gnu.tar.gz", "e9b6685001bc5a5d17acef15f3f6ffeb7beb6081926300f23ed4a442beac71ca"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/NNPACK.v2018.6.22.i686-linux-musl.tar.gz", "36c1d3c30b3bc3e0b34f215945bb46319f88e28f011fc758f21ba888b1fd9e25"),
    MacOS(:x86_64) => ("$bin_prefix/NNPACK.v2018.6.22.x86_64-apple-darwin14.tar.gz", "b30046223a11470b15a2ceb0d0df6f7d8a43260fe52f4a2f8ebe5f0b2df822ca"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/NNPACK.v2018.6.22.x86_64-linux-gnu.tar.gz", "150d5b6ca81fa72bfdc8bbda2428f0d3483fd11a5813724646c6d6c6a7ef969f"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/NNPACK.v2018.6.22.x86_64-linux-musl.tar.gz", "d961a104f814ec5b356519a82746a70a1df193ae37fc8130f38ffb61336def16"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    @warn "Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by NNPACK!
          You will only be able to use only the default NNlib backend."
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)