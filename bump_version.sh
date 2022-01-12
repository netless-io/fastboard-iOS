len() {
  echo ${#1}
}

NEWVERSION=$1
VERSIONLENGTH=$(len $NEWVERSION)
OLDTAG=$(git describe --abbrev=0)
echo 'input version is' $NEWVERSION
echo 'old Version is' $OLDTAG
if [ '0' = $VERSIONLENGTH ]; then
echo 'empty version, please try again'
exit 0
elif [ $OLDTAG = $NEWVERSION ]; then
echo 'version exist, please try again'
exit 0
else echo 'version enable'
fi

echo 'star bump version to' $NEWVERSION
sed -i '' 's/'$OLDTAG'/'$NEWVERSION'/g' Fastboard.podspec
echo 'update version text in podspec'
git add Fastboard.podspec
git commit -m 'Update podspec'
echo 'git commit'
git tag $NEWVERSION
echo 'add tag to git'
git push netless
echo 'push commit to netless'
git push netless --tags
echo 'push tags to netless'
echo 'begin push to trunk'
pod trunk push Fastboard.podspec --allow-warnings
echo 'successfully'

