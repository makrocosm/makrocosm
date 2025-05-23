# Custom scripting

Execute custom scripts in the `build/${path}` directory inside the workspace
container by defining a supported source script file and targeting the sentinel
file `build/${path}.exec`.


## Execute shell script

Execute a custom shell script in the `build/` directory using the workspace container
by defining an `${path}.sh` source script file and targeting `build/${path}.exec`
which will run the script in `build/${path}`.

  - Target: `build/${path}.exec`
  - Required dependencies:
    - `${path}.sh` - The shell script to run.
  - Built dependencies:
    - `build/${path}.src` - The sentinel file generated when the directory is
      downloaded to `build/${path}` using one of the
      [file fetching](file-fetch.md) rules.
