# Miscellaneous rules

## Pad file to size

Create a copy of a build artifact that is padded to the desired size.

  - Target: `build/${file}.pad`
  - Required dependencies:
    - `${file}.pad.cfg` -  See the configuration file details below.
  - Built dependencies:
    - `build/${file}` - The source file to pad to the desired size.

### Configuration file

The following options are valid in the `${file}.pad.cfg` configuration file.
  
  - `SIZE` - *Required* - The size of the target file to pad the dependency
  file to.
  If no units are provided, e.g. `1GB`, then the size is interpreted as bytes.
