#!/bin/bash

function log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - [${1:-INFO}] - ${2}" >> "script.log"
}

function verCheck() {
    echo "Checking if Clusterhelper is up to date."
    repo_url=$(echo ${YOUR_TRUECHARTS_REPO} | cut -d '@' -f 2 | tr ':' '/' | cut -d '.' -f 1,2 )
    repo_rul=$(echo https://${repo_url})
    repo_response=$(curl -s -o /dev/null -w "%{http_code}" --head ${repo_url})
    if [ ${repo_response} != "200" ]; then
        echo "Repo is private"
        return 0
        else
        echo "Repo is public. Cloning..."
        return 1
    fi
}

echo "Running Setup Check"

function repoMissing (){
    echo "Checking for repo"
    if [ -z "$( ls -A ${USER_MOUNT}/repo/ )" ]; then
        echo "Repo not found..."
        return 0
        else
        echo "Repo found..."
        return 1 
    fi
}

function keyMissing (){
    echo "Checking for keys"
    if [ -z "$( ls -A ${USER_MOUNT}/keys/ )" ]; then
        echo "ssh keys not found..."
        return 0
        else
        echo "ssh keys found..."
        return 1
    fi
}

function customScriptsMissing (){
    echo "Checking for custom scripts"
    if [ -z "$( ls -A ${USER_MOUNT}/scripts/user-custom/ )" ]; then
        echo "custom script example not found..."
        return 1
        else
        echo "custom script example found..."
        return 0
    fi
}

function customRunnersMissing (){
    echo "Checking for custom runners"
    if [ -z "$( ls -A ${USER_MOUNT}/runners/user-custom/ )" ]; then
        echo "custom runner example found..."
        return 1
        else
        echo "custom runner example found..."
        return 0
    fi
}

function repoPrivate () {
    echo "Checking if provided repo is private"
    repo_url=$(echo ${YOUR_TRUECHARTS_REPO} | cut -d '@' -f 2 | tr ':' '/' | cut -d '.' -f 1,2 )
    repo_rul=$(echo https://${repo_url})
    repo_response=$(curl -s -o /dev/null -w "%{http_code}" --head ${repo_url})
    if [ ${repo_response} != "200" ]; then
        echo "Repo is private"
        return 0
        else
        echo "Repo is public. Cloning..."
        return 1
    fi
}

function genSshKey() {
    echo "generating ssh key"
    ssh-keygen -q -t ed25519 -N '' -f ~/.ssh/id_ed25519 <<<y
    echo "please place your public key into github"
    echo "https://github.com/settings/ssh/new"
    cat ~/.ssh/id_ed25519.pub
    read -n 1 -s -r -p "Once your key is in github Press any key to continue..."
    echo "storing ssh keys..."
    cp ~/.ssh/id_* ${USER_MOUNT}/keys/
}

function gitClone() {
    cd ${USER_MOUNT}/repo
    pwd
    git clone ${YOUR_TRUECHARTS_REPO}
}

function gitClone() {
    cd ${USER_MOUNT}/repo
    pwd
    git clone ${YOUR_TRUECHARTS_REPO}
}

if [[ ! customScriptsFound ]] || [[ ! customRunnersFound ]]
then
    cp /app/conf/stash/example-script.sh /app/conf/scripts/user-custom/example-script.sh
    cp /app/conf/stash/example-script.json /app/conf/runners/user-custom/example-script.json
    if [[ customScriptsFound ]] && [[ customRunnersFound ]]
    then
        echo "could not copy example script and runner"
        exit 1
    fi
fi

if repoMissing
then
    if repoPrivate
    then
        if keyMissing
        then
            genSshKey
            if keyMissing
            then
                echo "ERROR: Key could not be generated or moved to proper location."
            else
                gitClone
            fi
        else
            echo "ssh key found for repo"
            getClone
        fi
    else
        echo "Repo is public"
        gitClone
    fi
fi

echo "Final evaluation"
repoMissing
repoPrivate
keyMissing
customScriptsMissing
customRunnersMissing

docker run -p 5000:5000  --name clusterhelper \
-v ~/clusterhelper/keys/:/app/conf/keys/ \
-v ~/clusterhelper/repo/:/app/conf/repo/ \
-v ~/clusterhelper/runners/:/app/conf/runners/user-custom/ \
-v ~/clusterhelper/scripts/:/app/conf/scripts/user-custom/ \
-v ~/clusterhelper/logs/:/app/logs \
clusterhelper:latest