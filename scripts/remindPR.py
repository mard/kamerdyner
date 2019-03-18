#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json, requests
from pprint import PrettyPrinter
import os
from dotenv import load_dotenv, find_dotenv
from requests.auth import HTTPBasicAuth

urlList = ["https://dev.azure.com/kantarware/kt-rio/_apis/git/repositories/KT-RIO-Storyteller-UI/pullrequests?api-version=5.0", "https://dev.azure.com/kantarware/kt-rio/_apis/git/repositories/KT-RIO-Viz-Service/pullrequests?api-version=5.0"]
load_dotenv(find_dotenv(), override=True)

class config:
    # HACKATON_SLACK_WEBHOOK_URL = os.environ.get('HACKATON_SLACK_WEBHOOK_URL')
    PAPUGA_SLACK_WEBHOOK_URL = os.getenv('PAPUGA_SLACK_WEBHOOK_URL')
    AZURE_USER_NAME = os.getenv('AZURE_USER_NAME')
    AZURE_PERSONAL_ACCESS_TOKEN = os.getenv('AZURE_PERSONAL_ACCESS_TOKEN')

class Data(object):
    def __init__(self, data):
        self.data = data

class PullRequest(object):
    def __init__(self, pullRequestId, service, owner, createdDate, title, sourceRefName):
        self.pullRequestId = pullRequestId
        self.service = service
        self.owner = owner
        self.createdDate = createdDate
        self.title = title
        self.sourceRefName = sourceRefName

    def toString(self):
        return ('PR id: ' + '<https://kantarware.visualstudio.com/KT-RIO/_git/KT-RIO-Storyteller-UI/pullrequest/' + self.pullRequestId + '?_a=overview|' + self.pullRequestId + '>' + '\n' + 
            'Serwis: ' + self.service + '\n' + 
            'Twórca: ' + self.owner + '\n' + 
            'Data założenia: ' + self.createdDate + '\n' + 
            'Tytuł: ' + self.title + '\n' + 
            'Nazwa Branch\'a: ' + self.sourceRefName) + '\n'

    def toStringShort(self):
        return ('Link do PR: ' + '<https://kantarware.visualstudio.com/KT-RIO/_git/KT-RIO-Storyteller-UI/pullrequest/' + self.pullRequestId + '?_a=overview|' + self.pullRequestId + '>' +
            ' Serwis: ' + self.service) +'\n'

class PullRequests(object):
    def __init__(self):
        self.items = []

    def add(self, pullRequest):
        self.items.append(pullRequest)

def readPullRequestsJson(url):
    req = requests.get(url, auth=HTTPBasicAuth(config.AZURE_USER_NAME, config.AZURE_PERSONAL_ACCESS_TOKEN))
    data = json.loads(req.text)
    return Data(data)

def getPullRequest(i, prData):
    pullrequestID = str(prData.data['value'][i]['pullRequestId'])
    service = (prData.data['value'][i]['repository']['name']).encode('utf-8')
    owner = (prData.data['value'][i]['createdBy']['displayName']).encode('utf-8')
    createdDate = (prData.data['value'][i]['creationDate']).encode('utf-8')
    title = (prData.data['value'][i]['title']).encode('utf-8')
    branch = (prData.data['value'][i]['sourceRefName']).encode('utf-8')
    return PullRequest(pullrequestID, service, owner, createdDate, title, branch)

def getPullRequestList():
    listPR = PullRequests()
    for url in urlList:
        prData = readPullRequestsJson(url)
        numberOfPR = prData.data['count']
        for i in range(numberOfPR):
            #get valuable data and create Pull Request object
            pr = getPullRequest(i, prData)
            #Add Pull Request to list
            listPR.add(pr)
    return listPR

def printPullRequests(listPR):    
    for pr in listPR.items:
        print pr.toString()

def messagePullRequests(listPR):   
    message = '' 
    for pr in listPR.items:
        message += pr.toString() + '\n'
    return message

def messageShortPullRequests(listPR):   
    message = '' 
    for pr in listPR.items:
        message += pr.toStringShort() + '\n'
    return message

class Kamerdyner:

    lastUnreadCount = -1

    def __init__(self, config):
        self.config = config
        print 'Started'

    def post(self, url, jsonObject):
        post = requests.post(url, data = jsonObject)
        if not post.ok:
            print 'Post to slack failed: ', post.content
            return True
        else:
            return False

    def postToSlack(self, say):
        userName = 'von Nogay'
        # slackMessage = json.dumps({ 'text': '#omnomnom', 'username': userName })
        # self.post(config.HACKATON_SLACK_WEBHOOK_URL, slackMessage)
        # time.sleep(4)
        slackMessage = json.dumps({ 'text': say, 'username': userName })
        self.post(config.PAPUGA_SLACK_WEBHOOK_URL, slackMessage)
        print '\t\tPosting to Slack {}'.format(slackMessage)

pullRequestList = getPullRequestList()
#printPullRequests(pullRequestList)
# printPullRequests(pullRequestList)
#messagePullRequests(getPullRequestList())
kamerdyner = Kamerdyner(config)
kamerdyner.postToSlack(messageShortPullRequests(pullRequestList))

print messageShortPullRequests(pullRequestList)