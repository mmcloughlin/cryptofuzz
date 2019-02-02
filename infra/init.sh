#!/bin/bash -e

# Terraform template variables ----------------------------------------------

GO_VERSION=${go_version}

# Local variables -----------------------------------------------------------

work_dir="/opt/fuzz"
gopath="$work_dir/gopath"

# Setup Working Directory ---------------------------------------------------

mkdir -p $work_dir

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
