import sys
import imaplib
import getpass
import email
import datetime
from email.header import decode_header
import requests
import json
import time
from dotenv import load_dotenv, find_dotenv
import os

load_dotenv(find_dotenv(), override=True)

class vendor(object):
    def __init__(self, name, keywords, say):
        self.name = name
        self.keywords = keywords
        self.say = say

    def toString(self):
        return 'name: "{:s}", keywords: {:s}, say: "{:s}"'.format(self.name, self.keywords, self.say)

class foodVendors(object):
    def __init__(self):
        self.items = []

    def searchKeywords(self, subject, keywords):
        for index, item in enumerate(keywords):
            if subject.lower().find(item) > -1:
                return True
        return False

    def findByKeyword(self, subject):
        matches = (v for v in self.items if self.searchKeywords(subject, v.keywords))
        return matches

    def add(self, vendor):
        self.items.append(vendor)

    def getSlackMessage(self, mailSubject):
        return "omnomnom"

    def getItems(self):
        return self.items

class kamerdyner:

    lastUnreadCount = -1

    def __init__(self, config, vendors):
        self.vendors = vendors
        self.config = config
        print 'Started'

    def decodeMailHeader(self, value):
        dh = email.header.decode_header(value)
        return u''.join([ unicode(t[0], t[1] or 'UTF-8') for t in dh ]).encode('utf-8').strip()

    def post(self, url, jsonObject):
        post = requests.post(url, data = jsonObject)
        if not post.ok:
            print 'Post to slack failed: ', post.content
            return True
        else:
            return False

    def postToSlack(self, say):
        userName = 'von Nogay'
        slackMessage = json.dumps({ 'text': '#omnomnom', 'username': userName })
        self.post(config.HACKATON_SLACK_WEBHOOK_URL, slackMessage)
        time.sleep(5)
        slackMessage = json.dumps({ 'text': say, 'username': userName })
        self.post(config.PAPUGA_SLACK_WEBHOOK_URL, slackMessage)
        print '\t\tPosting to Slack {}'.format(slackMessage)

    def processEmails(self):
        try:
            conn = imaplib.IMAP4_SSL(self.config.IMAP_SERVER)

            try:
                (retcode, capabilities) = conn.login(self.config.IMAP_USER, self.config.IMAP_PASSWORD)
            except:
                print 'It''s fucked: ', sys.exc_info()[1]
                sys.exit(1)

            conn.select(readonly=0) # Select inbox or default namespace
            (retcode, messages) = conn.search(None, '(UNSEEN)')
            if retcode == 'OK':
                msgs = messages[0].split()
                if(self.lastUnreadCount != len(msgs)):
                    print 'Unread count: {}'.format(len(msgs))
                    self.lastUnreadCount = len(msgs)
                for num in msgs:
                    print '\tmessage: {}'.format(num)
                    typ, data = conn.fetch(num, '(RFC822)')
                    msg = email.message_from_string(data[0][1])
                    subject = self.decodeMailHeader(msg['Subject'])
                    print '\t\tDate: {}, Subject {}'.format(msg['Date'], subject)
                    for found in self.vendors.findByKeyword(subject):
                        print '\t\tIdentified: {}'.format(found.name)
                        self.postToSlack(found.say)
                        # flag as seen
                        typ, data = conn.store(num,'+FLAGS','\\SEEN')
            conn.close()
        except:
            print 'Something fucked :/', sys.exc_info()[1]

# init vendors
vendors = foodVendors()
vendors.add(vendor('Smakosz', ['smakosz'], 'Bar smakosz'))
vendors.add(vendor('Eat zone', ['eat zone', 'eatzone'], 'Eat zone'))
vendors.add(vendor('Mr. Rollo', ['rollo'], 'Mister Rollo'))
vendors.add(vendor('Sushi', ['sushi'], 'sushiii'))

class config:
    HACKATON_SLACK_WEBHOOK_URL = os.environ.get('HACKATON_SLACK_WEBHOOK_URL')
    PAPUGA_SLACK_WEBHOOK_URL = os.environ.get('PAPUGA_SLACK_WEBHOOK_URL')
    IMAP_SERVER = os.environ.get('IMAP_SERVER')
    IMAP_USER = os.environ.get('IMAP_USER')
    IMAP_PASSWORD = os.environ.get('IMAP_PASSWORD')

kamerdyner = kamerdyner(config, vendors)

while True:
    kamerdyner.processEmails()
    time.sleep(30)
