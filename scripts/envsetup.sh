function hmm() {
cat <<EOF
Invoke ". scripts/envsetup.sh" from your shell to add the following 
functions to your environment:
EOF
    sort $(gettop)/.hmm |awk -F @ '{printf "%-30s %s\n",$1,$2}'
}

function gettop
{
    local TOPFILE=scripts/envsetup.sh
    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is
            # faked up with symlink names.
            PWD= /bin/pwd
        else
            # We redirect cd to /dev/null in case it's aliased to
            # a command that prints something as a side-effect
            # (like pushd)
            local HERE=$PWD
            T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
                cd .. > /dev/null
                T=`PWD= /bin/pwd`
            done
            cd $HERE > /dev/null
            if [ -f "$T/$TOPFILE" ]; then
                echo $T
            fi
        fi
    fi
}
T=$(gettop)
rm -f $T/.hmm $T/.hmmv
echo "gettop@display the top directory" >> $T/.hmm

function croot()
{
    T=$(gettop)
    if [ "$T" ]; then
        cd $(gettop)
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}
echo "croot@Change back to the top dir" >> $T/.hmm

function csgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f -name "*\.cs" -print0 | xargs -0 grep --color -n "$@"
}
echo 'csgrep@Grep through all csharp code' >> $T/.hmm

sb-reset ()
{
    (
    git clean -f -d -x
    git reset --hard HEAD
    )
}
echo 'sb-reset@CAUTION: Destructively resets to clean repo' >> $T/.hmm

sb-build-vars ()
{
    UNITY=/Applications/Unity/Unity.app/Contents/MacOS/Unity
#    XCODEBUILD=/usr/bin/xcodebuild
#    XCRUN=/usr/bin/xcrun
#    SECURITY=/usr/bin/security
#    PROVISIONING_GUID=SOME-GUID-GOES-HERE
#    CODESIGN_IDENTITY="iPhone Distribution: Joe Developer"
#    BUILD_DIR=../UnityClient/build
#    DEV_DIR="../UnityClient/"
#    KEYCHAIN_PASSWORD="Woohoo"
#    APP_NAME=shark-bomber
#    DEPLOY_DIR_IOS=$(gettop)/builds/ios
#    DEPLOY_DIR_ANDROID=$(gettop)/builds/android
}

sb-build-android ()
{
    (
    sb-build-vars

#    $UNITY \
#        -projectPath $(gettop)/shark-bomber    \
#        -executeMethod Build.Andorid    \
#        -batchmode \
#        -quit
    )
    echo "don't know how yet"
}
echo 'sb-build-android@Build shark-bomber for Android' >> $T/.hmm

sb-build-ios ()
{
    sb-build-vars

    $UNITY \
        -projectPath $(gettop)/shark-bomber \
        -executeMethod Build.iOS \
        -batchmode \
        -quit

    # Restore Info.plist that gets blown up during Unity build
#    git checkout -- ZyaStudio_Xcode/ZyaStudioiOS/Info.plist

}
echo 'sb-build-ios@Build shark-bomber for iOS' >> $T/.hmm

sb-ios-from-scratch ()
{
	sb-reset
	sb-build-ios
}
echo 'sb-io-from-scratch@CAUTION: Destructively build shark-bomber for iOS from scratch' >> $T/.hmm

unset T f