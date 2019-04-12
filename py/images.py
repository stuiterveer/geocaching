#!/usr/bin/python3

"""blah!"""

import json

class Images(object):
    """ Store logbook details in a class """

    cacheid = ""
    accountid = 0
    imageid = 0
    logid = 0
    filename = ""
    created = -1
    name = ""
    descr = ""

    def __init__(self):
        pass

    def __str__(self):

        output = {}
        output['cacheid'] = self.cacheid
        output['accountid'] = self.accountid
        output['imageid'] = self.imageid
        output['logid'] = self.logid
        output['filename'] = self.filename
        output['created'] = self.created
        output['name'] = self.name
        output['descr'] = self.descr

        return json.dumps(output)
