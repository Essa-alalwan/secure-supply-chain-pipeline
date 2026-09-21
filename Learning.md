# Learning Log

## Sample app and hash-pinned dependencies

### What I built
- A small FastAPI app (`app.py`) with two endpoints: `/health` and `/hello`.
- Two pytest tests (`test_app.py`). Result: 2 passed.
- Dependencies are managed with pip-tools. I list only the packages I choose
  in `requirements.in`, and `pip-compile --generate-hashes` produces a locked
  `requirements.txt` with exact versions and SHA-256 hashes.
- Dev-only tools (pytest, httpx) live in `requirements-dev.in`, so they stay
  out of the production image.

### What I noticed
- I asked for 2 packages (fastapi, uvicorn) and the lockfile contains 13.
  Examples I never chose: h11 (via uvicorn), anyio (via starlette),
  pydantic-core (via pydantic). These are transitive dependencies: code I
  run without picking it. This is what an SBOM will list.
- FastAPI serves interactive docs at `/docs` by default, and they are public.
  In production, teams often disable them so attackers don't get a map of the API.
- pytest showed 2 deprecation warnings from Starlette and anyio. They don't
  affect the result, so I'm ignoring them for now.

### Hash-pinning experiment
Goal: confirm that pip refuses a package that doesn't match the lockfile.

1. `pip install --require-hashes -r requirements.txt` printed
   "Requirement already satisfied" for everything. Hashes are only checked
   when pip downloads a file, so packages already installed were never verified.
2. Adding `--force-reinstall --no-cache-dir` made pip download everything fresh.
   All 13 packages passed the hash check.
3. My first tampering attempt didn't fail. A package lists several valid hashes
   (one per file variant), and pip only needs the hash of the file it actually
   downloads to match one of them.
4. After I changed the hash for the file pip actually downloads
   (annotated-doc, wheel), the install failed:

   ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE.
   Expected sha256 117cac03...   Got 117bac03...

   A one-character difference was enough to reject the package, and nothing
   was installed.

### Takeaways
- Hash pinning protects the moment a package is downloaded. It would stop a
  package swapped or tampered with on the registry after I locked it.
- It doesn't protect packages that are already installed, and it doesn't
  say whether a package is safe, only that it's the same file I locked.
  Malicious-package detection and vulnerability scanning are separate controls.
- Clean environments (like CI) matter, because they always download and verify.

### Next
- Dockerfile, then the first GitHub Actions workflow.