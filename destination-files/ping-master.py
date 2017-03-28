#!/usr/bin/python

import os
from slackclient import SlackClient

def ping_master(host):
    hostname = str(host)
    response = os.system("ping -c 1 " + hostname)
    if response == 0:
        pingstatus = "Network Active"
    else:
        pingstatus = "Network Error"
    return pingstatus


def send_slack(message):
    slack_token = "Slack Token Here"
    sc = SlackClient(slack_token)
    sc.api_call(
        "chat.postMessage",
        channel="#gehan-lab",
        text=str(message))

def main():

    pingstatus=ping_master("Master PI IP Here")

    if pingstatus=="Network Error":
            message="GEHAN-BRAMBLE ERROR MASTER PI IS DOWN"
            send_slack(message)
    else:
        message = "GEHAN-BRAMBLE ERROR MASTER PI IS OK"
        send_slack(message)

if __name__ == '__main__':
  main()