#!/bin/bash

WD=`pwd`
TEMP=`mktemp -d /tmp/mkframeworkXXXXXX`

show_help() {
cat << EOF
Usage: ${0##*/} [-hv] -l <DYNAMIC LIB> -s <HEADER DIR> -r <RESOURCE DIR> -n <NAME>
Create a .framework out of headers, a dynamic library and optional resources.

    -h          display this help and exit
    -v          verbose mode.
    -l          path to the dynamic lib
    -s          path to the directory containing the headers
    -r          path to the directory containing the resources (optional)
    -n          name of the library
EOF
}

if [ ! "$1" ]; then
    show_help
    exit 0
fi

INNAME=""
INLIB=""
INHEADERS=""
INRESOURCES=""
VERBOSE=0

OPTIND=1
while getopts "h?vl:s:r:n:" opt; do
    case "$opt" in
        h|\?)
            show_help
            exit 0
            ;;
        v)  verbose=$((VERBOSE+1))
            ;;
        l)  INLIB=$OPTARG
            ;;
        s)  INHEADERS=$OPTARG
            ;;
        r)  INRESOURCES=$OPTARG
            ;;
        n)  INNAME=$OPTARG
            ;;
    esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

if [ ! -n "$INNAME" -o ! -n "$INLIB" -o ! -n "$INHEADERS" ]; then
    echo "Missing arguments. Invoke with -h for help."
    exit 1
fi

OUTNAME="$INNAME.framework"
rm -rf $WD/$OUTNAME 2> /dev/null

mkdir $WD/$OUTNAME
mkdir $WD/$OUTNAME/Versions
mkdir $WD/$OUTNAME/Versions/A
mkdir $WD/$OUTNAME/Versions/A/Headers
mkdir $WD/$OUTNAME/Versions/A/Resources
mkdir $WD/$OUTNAME/Versions/A/Resources/en.lproj

cp $INLIB $WD/$OUTNAME/Versions/A/$INNAME
cp -R $INHEADERS/* $WD/$OUTNAME/Versions/A/Headers/
if [ -n "$INRESOURCES" ]; then
    cp -R $INRESOURCES/* $WD/$OUTNAME/Versions/A/Resources
fi

osascript -e "tell application \"Finder\" to make alias file to (POSIX file \"$WD/$OUTNAME/Versions/A/Headers\") at (POSIX file \"$WD/$OUTNAME/\")" > /dev/null
osascript -e "tell application \"Finder\" to make alias file to (POSIX file \"$WD/$OUTNAME/Versions/A/Resources\") at (POSIX file \"$WD/$OUTNAME/\")" > /dev/null
osascript -e "tell application \"Finder\" to make alias file to (POSIX file \"$WD/$OUTNAME/Versions/A/$INNAME\") at (POSIX file \"$WD/$OUTNAME/\")" > /dev/null
osascript -e "tell application \"Finder\" to make alias file to (POSIX file \"$WD/$OUTNAME/Versions/A\") at (POSIX file \"$WD/$OUTNAME\")" > /dev/null
mv $WD/$OUTNAME/A $WD/$OUTNAME/Versions/Current

touch $WD/$OUTNAME/Versions/A/Resources/en.lproj/InfoPlist.strings
read -d '' plist <<- EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>\$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>\$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>FMWK</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>\$(CURRENT_PROJECT_VERSION)</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2016 You. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string></string>
</dict>
</plist>
EOF

echo "$plist" > $WD/$OUTNAME/Versions/A/Resources/Info.plist
