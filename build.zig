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
    // we do the same here now.
    //

    //
    // base vorbis
    //
    const lib_vorbis = b.addLibrary(.{
        .name = "vorbis",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    lib_vorbis.addCSourceFiles(.{
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
    lib_vorbis.linkLibrary(lib_ogg);

    lib_vorbis.addIncludePath(upstream.path("include"));
    lib_vorbis.addIncludePath(upstream.path("lib"));

    lib_vorbis.installHeader(upstream.path("include/vorbis/codec.h"), "vorbis/codec.h");

    //
    // vorbisenc
    //
    const lib_enc = b.addLibrary(.{
        .name = "vorbisenc",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    lib_enc.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            // VORBISENC_SOURCES
            "vorbisenc.c",
        },
    });
    lib_enc.linkLibrary(lib_ogg);
    lib_enc.linkLibrary(lib_vorbis);

    lib_enc.addIncludePath(upstream.path("include"));
    lib_enc.addIncludePath(upstream.path("lib"));

    lib_enc.installHeader(upstream.path("include/vorbis/codec.h"), "vorbis/codec.h");
    lib_enc.installHeader(upstream.path("include/vorbis/vorbisenc.h"), "vorbis/vorbisenc.h");

    //
    // vorbisfile
    //
    const lib_file = b.addLibrary(.{
        .name = "vorbisfile",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .pic = pic,
        }),
    });

    lib_file.addCSourceFiles(.{
        .root = upstream.path("lib"),
        .files = &.{
            // VORBISFILE_SOURCES
            "vorbisfile.c",
        },
    });
    lib_file.linkLibrary(lib_ogg);
    lib_file.linkLibrary(lib_vorbis);

    lib_file.addIncludePath(upstream.path("include"));
    lib_file.addIncludePath(upstream.path("lib"));

    lib_file.installHeader(upstream.path("include/vorbis/codec.h"), "vorbis/codec.h");
    lib_file.installHeader(upstream.path("include/vorbis/vorbisfile.h"), "vorbis/vorbisfile.h");

    b.installArtifact(lib_vorbis);
    b.installArtifact(lib_enc);
    b.installArtifact(lib_file);
}
