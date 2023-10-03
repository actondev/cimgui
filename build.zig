const std = @import("std");
const LazyPath = std.Build.LazyPath;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const imgui = b.addStaticLibrary(.{
        .name = "imgui",
        .target = target,
        .optimize = optimize,
    });
    imgui.addIncludePath(.{ .path = "." });
    imgui.linkLibCpp();

    const imgui_flags = &[_][]const u8{};

    const imgui_src = &[_][]const u8{
        "cimgui.cpp",
        "imgui/imgui.cpp",
        "imgui/imgui_demo.cpp",
        "imgui/imgui_draw.cpp",
        "imgui/imgui_tables.cpp",
        "imgui/imgui_widgets.cpp",
    };
    imgui.addCSourceFiles(imgui_src, imgui_flags);

    // examples
    if (b.option(bool, "examples", "Build examples") orelse true) {
        const sdl_exe = b.addExecutable(.{
            .name = "sdl2_opengl3",
            .target = target,
            .optimize = optimize,
        });
        const SDL2 = b.dependency("SDL2", .{
            .target = target,
            .optimize = optimize,
        });

        sdl_exe.linkLibCpp();
        sdl_exe.addIncludePath(.{ .path = "./imgui" });
        sdl_exe.addIncludePath(.{ .path = "./imgui/backends" });
        sdl_exe.linkLibrary(imgui);
        sdl_exe.linkLibrary(SDL2.artifact("SDL2"));

        // TODO shouldnt' SDl2 add these inlcude dir?
        const sdl_incl = LazyPath.getPath(.{ .path = "include" }, SDL2.builder);
        sdl_exe.addIncludePath(.{ .path = sdl_incl });

        sdl_exe.addCSourceFiles(&[_][]const u8{
            "imgui/backends/imgui_impl_sdl2.cpp",
            "imgui/backends/imgui_impl_opengl3.cpp",
            "imgui/examples/example_sdl2_opengl3/main.cpp",
        }, &.{});
        b.installArtifact(sdl_exe);
    }
}
