# once all the local changes are staged and committed,
# update the version information in Cargo, push changes,
# create tag and push it too

# get current tagged version from git
touch tag.txt
git describe > tag.txt
LATEST_VERSION=$(grep -Po "(?<=v)\d.\d.\d" tag.txt)
echo $LATEST_VERSION > tag.txt
echo "Latest version: $LATEST_VERSION"

# calculate new version
VERSION_POSTFIX=$(grep -Po "\d$" tag.txt)
sed -i "s/$(grep -Po "\d$" tag.txt)/$(expr $VERSION_POSTFIX + 1)/g" tag.txt

TARGET_VERSION=$(cat tag.txt)
echo "Target version: $TARGET_VERSION"

# update Cargo files
CARGO_VERSION=$(grep -Po "(?<=^version = \")\d.\d.\d" Cargo.toml)
sed -i "s/$CARGO_VERSION/$TARGET_VERSION/g" Cargo.toml

cargo generate-lockfile -q

git add Cargo.toml
git add Cargo.lock

LAST_COMMIT_MSG=$(git log -n 1 --pretty=%B)
git commit --m "$LAST_COMMIT_MSG. Version updated: $LATEST_VERSION > $TARGET_VERSION"

git push

# create git tag with the message of the most recent commit
TAG="v$TARGET_VERSION"
git tag "$TAG" -m "$(git log -n 1 --pretty=%B)"
git describe

git push --tags

# cleanup
rm tag.txt