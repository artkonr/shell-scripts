# once all the local changes are staged and committed,
# update the version information in Cargo, push changes,
# create tag and push it too

# get current tagged version from git
touch tag.txt
git describe > tag.txt
LATEST_VERSION=$(grep -o "\d\.\d\.\d" tag.txt)
echo "$LATEST_VERSION" > tag.txt
echo "Latest version: $LATEST_VERSION"

# calculate new version
VERSION_POSTFIX=$(grep -o "\d$" tag.txt)
sed -i '.txt' "s/$(grep -o "\d$" tag.txt)/$(expr "$VERSION_POSTFIX" + 1)/g" tag.txt

TARGET_VERSION=$(cat tag.txt)
echo "Target version: $TARGET_VERSION"

# update Cargo files
touch cargo.txt
# extract prev version from Cargo.toml
grep -o "version\s*=\s*\"\d\.\d\.\d\"" Cargo.toml > cargo.txt
CARGO_PREV_VERSION=$(cat cargo.txt)
# change and save the new version
CARGO_VERSION=$(grep -o "\d\.\d\.\d" cargo.txt)
sed -i '.txt' "s/$CARGO_VERSION/$TARGET_VERSION/g" cargo.txt
CARGO_NEW_VERSION=$(cat cargo.txt)
sed -i '.txt' "s/$CARGO_PREV_VERSION/$CARGO_NEW_VERSION/g" Cargo.toml
# re-generate lock file
cargo generate-lockfile -q

git add Cargo.toml
git add Cargo.lock

LAST_COMMIT_MSG=$(git log -n 1 --pretty=%B)
git commit --m "$LAST_COMMIT_MSG. Version updated: $LATEST_VERSION > $TARGET_VERSION"

# create git tag with the message of the most recent commit
TAG="v$TARGET_VERSION"
git tag "$TAG" -m "$(git log -n 1 --pretty=%B)"
git describe

git push --atomic origin master $TAG

# cleanup
rm tag.txt
rm tag.txt.txt
rm Cargo.toml.txt
rm cargo.txt
rm cargo.txt.txt
