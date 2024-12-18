#!/bin/bash

function log() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - [${1:-INFO}] - ${2}"
}

function verCheck() {
    remote_version=$(curl -s https://raw.githubusercontent.com/itzteajay-glitch/clusterhelper/refs/heads/main/clusterhelper/conf/stash/version.json | grep version)
    local_version=$(cat /app/conf/stash/version.json | grep version)
    if [[ "${remote_version}" == "${local_version}" ]]; then
        log "INFO" "Clusterhelper up to date: ${local_version} == ${remote_version}"
        return 0
        else
        log "WARN" "Clusterhelper out of date: ${local_version} != ${remote_version}"
        while true; do
            log "INFO" "It is recommended you pull the most recent docker image for this."
            read -p "Would you like to continue on this version? (y/n): " yn

            case $yn in 
                [yY] )
                log "WARN" "version ignored"
                return 0
                break
                ;;
                [nN] )
                log "INFO" "user aborted due to version out of date"
                exit
                ;;
                * ) echo invalid response
                ;;
            esac
        done
    fi
}

function repoMissing (){
    if [ -z "$( ls -A ${USER_MOUNT}/repo/ )" ]; then
        log "WARN" "Repo not found"
        return 0
        else
        log "INFO" "Repo found"
        return 1 
    fi
}

function keyMissing (){
    if [ -z "$( ls -A ${USER_MOUNT}/keys/ )" ]; then
        log "WARN" "ssh keys not found"
        return 0
        else
        log "INFO" "ssh keys found"
        return 1
    fi
}

function customScriptsMissing (){
    if [ -z "$( ls -A ${USER_MOUNT}/scripts/user-custom/ )" ]; then
        log "WARN" "custom script example not found"
        return 0
        else
        log "INFO" "custom script example found"
        return 1
    fi
}

function customRunnersMissing (){
    if [ -z "$( ls -A ${USER_MOUNT}/runners/user-custom/ )" ]; then
        log "WARN" "custom runner example not found"
        return 0
        else
        log "INFO" "custom runner example found"
        return 1
    fi
}

function repoPrivate () {
    repo_url=$(echo ${YOUR_TRUECHARTS_REPO} | cut -d '@' -f 2 | tr ':' '/' | cut -d '.' -f 1,2 )
    repo_rul=$(echo https://${repo_url})
    repo_response=$(curl -s -o /dev/null -w "%{http_code}" --head ${repo_url})
    if [ ${repo_response} != "200" ]; then
        log "INFO" "Repo is private - ${repo_url} returned ${repo_response}"
        return 0
        else
        log "INFO" "Repo is public. Cloning..."
        return 1
    fi
}

function genSshKey() {
    log "INFO" "generating ssh key"
    ssh-keygen -q -t ed25519 -N '' -f ~/.ssh/id_ed25519 <<<y
    log "INFO" "please place your public key into github"
    log "INFO" "https://github.com/settings/ssh/new"
    cat ~/.ssh/id_ed25519.pub
    read -n 1 -s -r -p "Once your key is in github Press any key to continue..."
    log "INFO" "storing ssh keys"
    cp ~/.ssh/id_* ${USER_MOUNT}/keys/
}

function gitClone() {
    cd ${USER_MOUNT}/repo
    pwd
    git clone ${YOUR_TRUECHARTS_REPO}
    log "INFO" "Repo Cloned"
}

if verCheck; then
    log "INFO" "version check complete"
fi

if customScriptsMissing || customRunnersMissing; then
    cp /app/conf/stash/example-script.sh /app/conf/scripts/user-custom/example-script.sh
    cp /app/conf/stash/example-script.json /app/conf/runners/user-custom/example-script.json
    if customScriptsMissing && customRunnersMissing; then
        log "ERROR" "could not copy example script and runner"
        exit 1
    else
        log "INFO" "example scripts pulled in from stash"
    fi
fi

if repoMissing && repoPrivate; then
    if keyMissing; then
        genSshKey
        if keyMissing; then
            log "ERROR" "Key could not be generated or moved to proper location"
        else
            gitClone
        fi
    else
        log "INFO" "ssh key found for repo"
        getClone
    fi
fi
if repoMissing && ! repoPrivate; then
    log "INFO" "Repo is public. But does not exist"
    gitClone
fi

log "INFO" "Final evaluation"
repoMissing
repoPrivate
keyMissing
customScriptsMissing
customRunnersMissing