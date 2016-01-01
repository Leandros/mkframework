# Make Framework
A simple bash script to create an OS X framework.

# Usage
```
Usage: ./mkframework.sh [-hv] -l <DYNAMIC LIB> -s <HEADER DIR> -r <RESOURCE DIR> -n <NAME>
Create a .framework out of headers, a dynamic library and optional resources.

    -h          display this help and exit
    -v          verbose mode.
    -l          path to the dynamic lib
    -s          path to the directory containing the headers
    -r          path to the directory containing the resources (optional)
    -n          name of the library
```

