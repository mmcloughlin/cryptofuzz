function heading()
{
    local sep='-----------------------------------------------------------------------------'
    echo ${sep}
    echo $1
    echo ${sep}
}

function targets()
{
    ls -1 $(local_path "")
}

function local_path()
{
    echo -n "target/$1"
}

function target_import_path()
{
    local repo='github.com/mmcloughlin/cryptofuzz'
    echo -n "${repo}/$(local_path $1)"
}

function bin_file()
{
    echo -n "$(local_path $1)/bin.zip"
}

function fuzz_files()
{
    echo $(bin_file $1)
    for datadir in corpus crashers suppressions; do
        datapath="$(local_path $1)/${datadir}"
        if [ -d ${datapath} ]; then
            echo $datapath
        fi
    done
}

function package_dir()
{
    go list -f '{{ .Dir }}' $1
}

function package_files_for_arch()
{
    local pkg=$1
    local arch=$2
    GOOS=linux GOARCH=${arch} go list -f '
        {{ join .GoFiles " "}}
        {{ join .TestGoFiles " "}}
        {{ join .XTestGoFiles " "}}
        {{ join .SFiles " " }}
        {{ join .HFiles " " }}
    ' ${pkg}
}

function clear_build_tags()
{
    local path=$1
    sed -i.bak '/+build/d' ${path}/*
    rm -rf ${path}/*.bak
}

function clear_import_path_assertions()
{
    local path=$1
    sed -i.bak 's/\/\/ import.*//' ${path}/*
    rm -rf ${path}/*.bak
}

function fork_package_for_arch()
{
    local pkg=$1
    local arch=$2
    local dst=$3

    mkdir -p ${dst}

    dir=$(package_dir ${pkg})
    for filename in $(package_files_for_arch ${pkg} ${arch}); do
        cp -v ${dir}/${filename} ${dst}
    done

    clear_build_tags ${dst}
    clear_import_path_assertions ${dst}
}

function clone_package()
{
    local pkg=$1
    local dst=$2

    mkdir -p ${dst}
    cp $(package_dir ${pkg})/* ${dst}

    clear_import_path_assertions ${dst}
}

function rewrite_imports()
{
    local path=$1
    local from=$2
    local to=$3

    find ${path} -type f | xargs sed -i.bak "s|${from}|${to}|"
    find ${path} -name '*.bak' | xargs rm -rf
}