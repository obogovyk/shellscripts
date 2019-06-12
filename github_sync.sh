#!/bin/bash

export LC_LANG=en_US.utf8

# Github credentials
LOGIN=''
TOKEN=''

# List of Gitlab repositories
GITLAB_REPOS=(
	"http://gitlab.com/project/repo.git"
)

MISSED_REPOS=()

create_missing_repos() {
    curl -X POST https://partner-github.example.com/api/v3/orgs/project/repos -u ${USER}:${TOKEN} -d '{"name": "${r%.*}", "private": true}' > /dev/null 2>&1
    echo "${r%.*}"
done
}

# Find missing repos on Github
for i in ${GITLAB_REPOS[@]}; do
    git ls-remote https://${LOGIN}:${TOKEN}@partner-github.example.com/project/${i##*/} > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        MISSED_REPOS+=(${i##*/})
    fi
done

# List missing repos on Github
echo "Not existing repos on Github:"
for mr in ${MISSED_REPOS[@]}; do
    echo "https://partner-github.example.com/project/${mr}"
done

# Create missing repoositories if needed
echo -n "Do you want to proceed creating missing repositories?"
read yn
case $yn in
    [Yy]* ) create_missing_repos;;
    [Nn]* ) exit 0;;
    * ) echo "Please answer yes or no."; exit 1;;
esac
