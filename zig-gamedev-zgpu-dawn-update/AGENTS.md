src/wgpu.zig is meant to wrap the API exposed in lib/include/webgpu.h.

All that occurs in the zig build process (as seen in build.zig) is that some zig tests are run to test ABI compatibility between wgpu.zig and webgpu.h.

I have spent a good deal of time modifying wgpu.zig already to match a newer version of Dawn, which might be to say, a newer version of the WebGPU API.

There are still many changes that need to be made, though. Structs have fallen out of sync. Some exist in wgpu.zig that no longer exist in webgpu.h.
Other new structs may now exist in webgpu.h that need to be mirrored in wgpu.zig.
Enums have likewise fallen out of sync, and so have some function names.

It's tedious, slow work, and I thought I'd let you have a try at it today.

Thoroughly read and understand the API laid out by webgpu.h, and take whatever steps you can to bring wgpu.zig back into compliance.

I am including an old copy of wgpu.zig from before I started all of this reworking to get it to align with a new version of Dawn/WebGPU.
This is found in old_src/wgpu.zig. Do not edit or modify this file. I'm including it here so that you can compare it to the newer, but still incomplete,
version found in src/wgpu.zig. Comparing them, if you feel the need (you don't have to at all), might help you see how I've been making changes so far.

The tests themselves, one which compares struct ABI, and another which compares enum values, may not function perfectly, and may need improvements or fixes.
They can be found at the bottom of wgpu.zig. When balancing whether you should change the code to conform to the test, or change the test to
conform to the code, consider the consistency of the naming scheme you can see is evident throughout wgpu.zig already.
If the normalizeCEnumField function at the bottom of the file needs a tweak to accept some struct name or enum name that best fits the naming scheme,
then tweak it. But if a name that would pass the existing test also fits just as well, perhaps change the name of the struct or enum instead.

To test your changes (and to also test the current state of this mess to see where to start fixing things, if you want), run `zig build test` from this directory.

The tests do not yet cover things like function pointer type declarations, I believe. Don't assume that everything is correct just because the tests pass.
If you feel that it wouldn't be too hard to write another test like the ones for structs and enums, but to check stuff that isn't being checked, try it.

If you are unsure how best to bring some certain part of wgpu.zig into alignment with the API (and implied usage practices) found in webgpu.h,
just skip that certain part and move onto another thing that needs fixing.

When you are about out of time for your task, even if you have not completed all that you wanted to, commit the changes anyway.
Partial completion of the task is preferable to giving up and saying you ran out of time.