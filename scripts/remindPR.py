#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json, urllib2
from pprint import PrettyPrinter

urlList = ["http://172.23.14.198/kamerdyner/tmp/pull-requests-response.json", "http://172.23.14.198/kamerdyner/tmp/KT-RIO-Viz-Service-pullrequests.json"]

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
        return ('PR id: ' + self.pullRequestId + '\n' + 
            'Serwis: ' + self.service + '\n' + 
            'Twórca: ' + self.owner + '\n' + 
            'Data założenia: ' + self.createdDate + '\n' + 
            'Tytuł: ' + self.title + '\n' + 
            'Nazwa Branch\'a: ' + self.sourceRefName) + '\n'

class PullRequests(object):
    def __init__(self):
        self.items = []

    def add(self, pullRequest):
        self.items.append(pullRequest)

def readPullRequestsJson(url):
    req = urllib2.Request(url)
    opener = urllib2.build_opener()
    f = opener.open(req)
    data = json.loads(f.read())
    main = Data(data)
    return main

def getPullRequest(i, url):
    pullrequestID = str(readPullRequestsJson(url).data['value'][i]['pullRequestId'])
    service = (readPullRequestsJson(url).data['value'][i]['repository']['name']).encode('utf-8')
    owner = (readPullRequestsJson(url).data['value'][i]['createdBy']['displayName']).encode('utf-8')
    createdDate = (readPullRequestsJson(url).data['value'][i]['creationDate']).encode('utf-8')
    title = (readPullRequestsJson(url).data['value'][i]['title']).encode('utf-8')
    branch = (readPullRequestsJson(url).data['value'][i]['sourceRefName']).encode('utf-8')
    return PullRequest(pullrequestID, service, owner, createdDate, title, branch)

def getPullRequestList():
    listPR = PullRequests()
    for url in urlList:
        numberOfPR = readPullRequestsJson(url).data['count']
        for i in range(numberOfPR):
            #get valuable data and create Pull Request object
            pr = getPullRequest(i, url)
            #Add Pull Request to list
            listPR.add(pr)
    return listPR

def printPullRequests(listPR):    
    for pr in listPR.items:
        print pr.toString()

pullRequestList = getPullRequestList()
printPullRequests(pullRequestList)