#!/bin/bash
set -eo pipefail

die()
{
    echo "$@" >&2
    exit 1
}

usage()
{
    cat <<EOF
usage: git scaffold <name> <project>
EOF
    exit 1
}

scaffold_repo()
{
    git config --get "scaffold.$1.repo" \
        || git config --get scaffold.default.repo \
        || die "missing: git config --set scaffold.default.repo"
}

scaffold_refspec()
{
    git config --get "scaffold.$1.refspec" || printf "%s" "$1"
}

template()
{
    grep -v ./.git/ > "${TMPDIR:-/tmp}/$$.tmp"
    < "${TMPDIR:-/tmp}/$$.tmp" while read -r file ; do
        new_file="$(echo "${file}" | template_sed)"
        [ "${new_file}" != "${file}" ] && mv "${file}" "${new_file}"
        if [ -f "${new_file}" ]; then
            template_sed -i "" "${new_file}"
        fi
    done
}

template_sed()
{
    sed -e "s/__PROJECT_TEMPLATE_SNAKE__/${TEMPLATE_SNAKE:?}/g" \
        -e "s/__PROJECT_TEMPLATE_CAMEL__/${TEMPLATE_CAMEL:?}/g" \
        -e "s/__PROJECT_TEMPLATE_AUTHOR__/${TEMPLATE_AUTHOR:?}/g" \
        -e "s/__PROJECT_TEMPLATE_EMAIL__/${TEMPLATE_EMAIL:?}/g" \
        "$@"
}

snake2camel()
{
    echo "$@" | perl -pe 's/(^|_)./uc($&)/ge;s/_//g'
}

scaffold="$1"
project="$2"
shift || usage

if [ -z "${project}" ]; then
    project="${PWD##*/}"
else
    (mkdir "${project}" && cd "${project}") || die
fi

git init
git pull --squash "$(scaffold_repo "${scaffold}")" "$(scaffold_refspec "${scaffold}")"

: "${TEMPLATE_SNAKE:=${project}}"
: "${TEMPLATE_CAMEL:=$(snake2camel "${TEMPLATE_SNAKE}")}"
: "${TEMPLATE_AUTHOR:=$(git config --get user.name)}"
: "${TEMPLATE_EMAIL:=$(git config --get user.email)}"

find . -type d -print | template
find . -type f -print | template

git add --all
git commit --amend -C HEAD
