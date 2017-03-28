#!/usr/bin/python

import os
from os.path import join
from os import listdir
from slackclient import SlackClient

def check_retry(path):
    check=os.path.exists(path)
    return check, path

def read_retry(path):
    retry_file=open(path,"r")
    lines=retry_file.readlines()
    return lines

def remove_retry_files(dir):
    dir=str(dir)
    list = os.listdir(dir)
    for item in list:
        if item.endswith(".retry"):
            os.remove(join(dir, item))

def send_slack(message):
    slack_token = "slack token here"
    sc = SlackClient(slack_token)
    sc.api_call(
        "chat.postMessage",
        channel="#gehan-lab",
        text=str(message))

def main():

    retry_result, path=check_retry("/home/pi/gehan-bramble/playbooks/ping-hosts.retry")

    if retry_result==True:
        lines=read_retry(path)
        for x in lines:
            x=x.rstrip('\n')
            message="Host "+str(x)+" is Down"
            send_slack(message)
        remove_retry_files("/home/pi/gehan-bramble/playbooks/")
    else:
        pass

if __name__ == '__main__':
  main()