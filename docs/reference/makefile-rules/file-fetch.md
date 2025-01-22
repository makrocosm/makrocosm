# File fetch

Fetch files from another location and write into the `build/` directory.
This is used by Makrocosm's Linux kernel and u-boot Makefile rules to
make the source code for those projects available for building.

The following file fetching Makefile rules target the sentinel file
`build/${file}.src` although the data itself is located at `build/${file}`.
The sentinel file is used because last modification timestamps on directories
are unreliable for the purposes of dependency rebuild evaluation.

Other Makefile rules that depend on fetched files should depend on the sentinel
file only, and make will choose a file fetching rule depending on which required
dependencies are satisfied.

## Download file

Download a file to `build/${file}`, or optionally extract it to a directory
at that location if it is a file archive.

  - Target: `build/${file}.src`
  - Required dependencies:
      - `${file}.download.cfg` - See the configuration file details below. 
  - Optional dependencies:
     - `*.patch` - Patches to apply to the downloaded repository, applicable
       if the download is an extracted archive.

### Configuration file

The following options are valid in the `${file}.download.cfg` configuration file.
  
  - `URL` - *Required* - The URL to download the file from.
    May specify any of the protocols supported by curl in the workspace
    container, e.g. `https://`, `ftp://`, etc.
  - `SHA256` - *Optional* - The file's SHA256 checksum to validate the
     integrity of the file after downloading.
  - `FORMAT` - *Optional* - Hint archive file format for extraction if the
    filename is not suffixed with one of the following extensions:
    `tar`, `tar.gz`, `tar.bz2` `tar.xz`, `tgz`.
  - `EXTRACT` - *Optional* - Extract the archive to the directory
     Default: `y` if the file is an archive.
  - `STRIP` - *Optional* - The number of leading directories to strip
     when extractin files from the archive.
     Default: `1`.

## Clone Git repository

  - Target: `build/${file}.src`
  - Required dependencies:
      - `${file}.git.cfg` - See the configuration file details below.  
  - Optional dependencies:
     - `*.patch` - Patches to apply to the downloaded repository.

### Configuration file

The following options are valid in the `${file}.git.cfg` configuration file.
  
  - `URL` - *Required* - The URL of the Git repository to clone.
  - `REFNAME` - *Required* - 
