#!/bin/bash -e

# Terraform template variables ----------------------------------------------

GO_VERSION=${go_version}
DEPLOY_KEY="${deploy_private_key}"
TARGET="${target}"

# Local variables -----------------------------------------------------------

repo_import_path="github.com/mmcloughlin/cryptofuzz"
repo_clone_url="git@github.com:mmcloughlin/cryptofuzz.git"

work_dir="/opt/fuzz"
gopath="$work_dir/gopath"
secret="$work_dir/secret"
repo_dir="$gopath/src/$repo_import_path"

# Setup Working Directory ---------------------------------------------------

mkdir -p $work_dir $secret $repo_dir

# Install Go ----------------------------------------------------------------

go_archive="go$GO_VERSION.linux-amd64.tar.gz"
go_download_url="https://dl.google.com/go/$go_archive"
local_archive_path="/tmp/$go_archive"

wget -O $local_archive_path $go_download_url
tar -C $work_dir -xzf $local_archive_path go

export GOPATH="$gopath"
export PATH="$PATH:$work_dir/go/bin:$GOPATH/bin"

# Install go-fuzz -----------------------------------------------------------

go get -u github.com/dvyukov/go-fuzz/...

# Clone repository ----------------------------------------------------------

deploy_key_path="$secret/deploy_key"
echo -n "$DEPLOY_KEY" > $deploy_key_path
chmod 0400 $deploy_key_path

# add github to known hosts (https://help.github.com/articles/github-s-ssh-key-fingerprints/)
cat > ~/.ssh/known_hosts <<EOF
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF

GIT_SSH_COMMAND="ssh -i $deploy_key_path" git clone $repo_clone_url $repo_dir

# Start fuzzer --------------------------------------------------------------

cd $repo_dir
./script/fuzz $TARGET
