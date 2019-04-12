#!/usr/bin/python3

"""blah!"""

import json

class LogBook(object):
    """ Store logbook details in a class """

    cacheid = ""
    logid = 0
    accountid = 0
    logtype = ""
    logimage = ""
    logtext = ""
    created = -1
    visited = -1

    def __init__(self):
        pass

    def __str__(self):

        output = {}
        output['cacheid'] = self.cacheid
        output['logid'] = self.logid
        output['accountid'] = self.accountid
        output['logtype'] = self.logtype
        output['logimage'] = self.logimage
        output['logtext'] = self.logtext
        output['created'] = self.created
        output['visited'] = self.visited

        return json.dumps(output)
