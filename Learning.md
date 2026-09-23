# Learning Log

### App
Built a tiny FastAPI app (2 endpoints, /health and /hello) just to have
something for the pipeline to run on. Nothing fancy on purpose.

### Hash pinning
Used pip-compile to lock dependencies with hashes. Only asked for 2
packages (fastapi, uvicorn) and ended up with 13 in the lockfile. Didn't
expect that many transitive deps. Things like h11 and anyio just show up
because uvicorn/starlette need them, not because I picked them.

Tried to break the hash pinning to see if it actually does anything. First
attempt failed to fail. Turns out pip accepts a package if ANY of its
listed hashes match, and I only broke one of several. Had to actually
corrupt all the hashes for a package before pip refused it. Good reminder
that this protects you at download time, not just because a hash file
exists.

### Docker
Mostly fine except uvicorn wasn't found when running the container. Turns
out I only copied site-packages from the build stage and forgot
/usr/local/bin, which is where the actual uvicorn command lives. Fixed it
and re-tested that the container runs as non-root.

### CI (GitHub Actions)
Every run starts on a completely empty machine, so it reinstalls
everything from scratch every time. Kind of annoying at first, but that's
actually the point. It proves the project isn't just "works on my
machine."

### SBOM
Added SBOM generation with Syft. Downloaded and looked through it: about
47 real packages (13 python + ~33 debian system packages), plus a file
hash for basically every file in the image. Found stuff like openssl and
libc6 in there that I never installed myself, they came from the base
image. That's basically the whole point of an SBOM. requirements.txt only
shows what I asked for; the SBOM shows what's actually there.

### Next
Vulnerability scanning, then OPA policies.