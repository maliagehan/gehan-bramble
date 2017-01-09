#!/bin/bash
source /home/clizarraga/usr/local/ansible/hacking/env-setup
# ansible-playbook=/usr/bin/ansible-playbook
PREV_DIR=$(pwd)
ANSIBLE_PLAYBOOKS=$(dirname $1)
cd $ANSIBLE_PLAYBOOKS
function retry_log {
    # Making a backup of the retry file, as well as making sure it's unique
    retry_name=logs/$playbook_name.script.retry.bak
    manual_log=logs/$playbook_name.script.retry
    # The normal retry should not capture failed hosts, so we need to capture them.
    # Grepping failed hosts.
    grep -e 'failed:' $ANSIBLE_LOG_PATH | awk '{print $7}' | sed 's/\[//' | sed 's/\]//' > $manual_log
    # Grepping UNREACHABLE hosts.
    grep -e 'UNREACHABLE' $ANSIBLE_LOG_PATH | awk '{print $7}' | sed 's/\[//' | sed 's/\]://' >> $manual_log
    # Sometimes a host is both failed and unreachable, therefore we make sure we only have unique hostnames/IPs.
    sort -u $manual_log $playbook_name.retry > logs/temp.file.log
    mv logs/temp.file.log $manual_log
    # Make a backup log file.
    cp $manual_log $retry_name
    if [[ -s $manual_log ]]; then
        echo "$manual_log has data, continuing..."
        mv $ANSIBLE_LOG_PATH $ANSIBLE_LOG_PATH.$(date +%Y-%m-%d-%H).bak
    else
        echo "$manual_log is empty, exiting"
        mv $ANSIBLE_LOG_PATH $ANSIBLE_LOG_PATH.$(date +%Y-%m-%d-%H).bak
        exit
    fi
}

# Making a playbook specific ansible log
# There may be a date-time specific one later
playbook_name=$(basename $1 | cut -d . -f 1)
export ANSIBLE_LOG_PATH=$(pwd)/logs/playbook_$playbook_name.log

# Calling the ansible-playbook with all the parameters.
ansible-playbook $@

# Making the script wait at least 10 seconds before retrying
sleep 10

# Calling retry log function
retry_log

mv $playbook_name.retry logs/$playbook_name.retry.bak
mv $ANSIBLE_LOG_PATH $ANSIBLE_LOG_PATH.bak
# Call ansible with the same parameters, overriding the old timeout value and using the host list
ansible-playbook $@ -T 20 -l @$manual_log

# Making the script wait at least 10 seconds before retrying
sleep 10

# Calling retry log function for the second retry.
retry_log

mv $playbook_name.retry logs/$playbook_name.retry.bak
mv $ANSIBLE_LOG_PATH $ANSIBLE_LOG_PATH.bak
# Call ansible with the same parameters, overriding the old timeout value and using the host list
ansible-playbook $@ -T 30 -l @$manual_log

rm *.log
rm *.retry
cd $PREV_DIR
