const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const pic = b.option(bool, "pic", "Enable Position Independent Code option");

    const upstream = b.dependency("vorbis", .{});

    const dep_ogg = b.dependency("ogg", .{
        .target = target,
        .optimize = optimize,
    });
    const lib_ogg = dep_ogg.artifact("ogg");

    //
    // upstream vorbis' builds 3 different libraries: vorbis, vorbisenc and vorbisfile.
    // since we're doing a static library build, we can just join them into 1 for simplicity.
    //
    const lib = b.addLibrary(.{
        .name = "vorbis",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    lib.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            // VORBIS_SOURCES
            "mdct.c",
            "smallft.c",
            "block.c",
            "envelope.c",
            "window.c",
            "lsp.c",
            "lpc.c",
            "analysis.c",
            "synthesis.c",
            "psy.c",
            "info.c",
            "floor1.c",
            "floor0.c",
            "res0.c",
            "mapping0.c",
            "registry.c",
            "codebook.c",
            "sharedbook.c",
            "lookup.c",
            "bitrate.c",
            // VORBISFILE_SOURCES
            "vorbisfile.c",
            // VORBISENC_SOURCES
            "vorbisenc.c",
        },
    });
    lib.linkLibrary(lib_ogg);

    lib.addIncludePath(upstream.path("include"));
    lib.addIncludePath(upstream.path("lib"));

    lib.installHeadersDirectory(upstream.path("include/vorbis"), "vorbis", .{});
    b.installArtifact(lib);
}
