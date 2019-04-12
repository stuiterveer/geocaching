#!/usr/bin/python3

import os
import sqlite3
import time
import datetime
import pickle
import math
from html.parser import HTMLParser
from html import unescape
import json
import shutil
import requests
import geocache
import images
import logbook
import users
from bs4 import BeautifulSoup, NavigableString

APP_ID = os.environ.get("APP_ID", "").split('_')[0]
CONFIGBASE = os.environ.get("XDG_CONFIG_HOME", "/tmp") + "/" + APP_ID
DBBASE = os.environ.get("XDG_DATA_HOME", "/tmp") + "/" + APP_ID
CACHEBASE = os.environ.get("XDG_CACHE_HOME", "/tmp") + "/" + APP_ID

HEADERS = {}
HEADERS['User-Agent'] = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 "
HEADERS['User-Agent'] += "(KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"

SESSION = requests.session()
SESSION.headers = HEADERS

TOKEN = ""

def getSession():
    global SESSION

    checkPath()

    print("Attempting to reload the previous session.")

    try:
        filename = CONFIGBASE + "/session.bin"
        with open(filename, 'rb') as f:
            SESSION = pickle.load(f)

        SESSION.headers = HEADERS
        print("Session re-loaded.")
        return
    except Exception as error:
        print("line 50 - Failed to load session, see below for trace.")
        print(error)
        SESSION = requests.Session()
        SESSION.headers = HEADERS
        return

def saveSession():
    checkPath()

    print("Attempting to save the session.")

    try:
        filename = CONFIGBASE + "/session.bin"
        with open(filename, 'wb') as f:
            pickle.dump(SESSION, f)
        print("Session saved.")
    except Exception as error:
        print("line 67 - Failed to save session, see below for trace.")
        print(error)

def getAuth():
    username = ""
    password = ""

    getSession()

    data = readFile("geocaching.ini")
    for line in data.split("\n"):
        if line.split("=", 1)[0] == "username":
            username = line.split("=", 1)[1]
        if line.split("=", 1)[0] == "password":
            password = line.split("=", 1)[1]

    return [username, password]

def gclogin(username, password):
    loginok = 0

    loginok, response = isLoggedIn()

    if loginok == 0:
        data = doAuth(username, password)
        response = data.text
        if "li-user-info" in response:
            data = "username=" + username  + "\npassword=" + password + "\n"
            writeFile("geocaching.ini", data)
            loginok = 1
            saveSession()
    else:
        loginok = 1

    return [loginok, response]

def getLogTypes(cacheid):
    global TOKEN
    cacheid = cacheid.upper()
    url = "https://www.geocaching.com/play/geocache/" + cacheid.lower() + "/log"
    html = SESSION.get(url)
    data = html.text

    TOKEN = html.text.split('__RequestVerificationToken', 1)[1]
    TOKEN = TOKEN.split('value="', 1)[1].split('"', 1)[0].strip()

    logtypes = data.split('<select class="log-type" name="LogTypeId">', 1)[1]
    logtypes = logtypes.split('</select>', 1)[0].strip()

    logtypes = logtypes.split('<option value="')

    log_arr = []
    for line in logtypes:
        line.strip()
        if line == "":
            continue

        type_id = line.split('">', 1)[0].strip()
        type_text = unescape(line.split('">', 1)[1].split('</option>')[0].strip())
        log_arr.append({"type_id": type_id, "type_text": type_text})

    print(log_arr)
    return json.dumps(log_arr)

def logvisit(cacheid, logtype, logdate, logtext):
    cacheid = cacheid.upper()
    url = "https://www.geocaching.com/play/geocache/" + cacheid.lower() + "/log"

    now = datetime.datetime.now()

    if logdate == "Today":
        logdate = now.strftime("%Y-%m-%d")
    else:
        yesterday = now - datetime.timedelta(days=1)
        logdate = yesterday.strftime("%Y-%m-%d")

    logtypeid = getLogTypeID(logtype)

    data = {}
    data['__RequestVerificationToken'] = TOKEN
    data['LogTypeId'] = logtypeid
    data['LogDate'] = logdate
    data['LogText'] = logtext

    # print(url)
    # print(data)

    try:
        # TODO: check for reply in case of failure for whatever reason...
        SESSION.post(url, data=data)
        return True
        # response = SESSION.post(url, data=data)
        # print(response.html)
    except Exception as error:
        print("line 157")
        print(error)
        return error

def getLogTypeID(logtype):
    # found_it = "2"
    # didnt_find_it = "3"
    # note = "4"
    # archive = "5"
    # will_attend = "9"
    # attended = "10"
    # webcam_photo_taken = "11"
    # unarchive = "12"
    # retrieved_it = "13"
    # placed_it = "14"
    # post_reviewer_note = "18"
    # temp_disable_listing = "22"
    # enable_listing = "23"
    # publish_listing = "24"
    # retract = "25"
    # needs_maintenance = "45"
    # owner_maintenance = "46"
    # update_coordinates = "47"
    # discovered_it = "48"
    # announcement = "74"
    # visit = "75"
    # submit_for_review = "76"
    # oc_team_comment = "83"

    print("logtype == " + logtype)

    if logtype == "Found It":
        return 2
    elif logtype == "Didn't Find It":
        return 3
    elif logtype == "Write note":
        return 4
    elif logtype == "Owner maintenance":
        return 5
    elif logtype == "Will attend":
        return 9
    elif logtype == "Attended":
        return 10
    elif logtype == "Disable":
        return 22
    elif logtype == "Publish Listing":
        return 24
    elif logtype == "Owner maintenance":
        return 46
    elif logtype == "Update coordinates":
        return 47
    return 4

def doAuth(username, password):
    url = "https://www.geocaching.com/account/signin"
    html = SESSION.get(url)

    tokenField = html.text.split('__RequestVerificationToken', 1)[1]
    tokenField = tokenField.split('value="', 1)[1].split('"', 1)[0].strip()

    data = {}
    data['UsernameOrEmail'] = username
    data['Password'] = password
    data['__RequestVerificationToken'] = tokenField
    data['ReturnUrl'] = ""

    response = SESSION.post(url, data=data)

    return response

def isLoggedIn():
    url = "https://www.geocaching.com/play/search"
    html = SESSION.get(url)

    if "li-user-info" in html.text:
        print("User logged in, skipping re-auth")
        return [1, html.text]

    print("User not logged in, not skipping re-auth")
    return [0, html.text]

def checkPath():
    os.makedirs(CONFIGBASE, exist_ok=True)
    os.makedirs(DBBASE, exist_ok=True)
    os.makedirs(CACHEBASE, exist_ok=True)

def readFile(filename):
    checkPath()

    try:
        filename = CONFIGBASE + "/" + filename
        my_file = open(filename, "r+")
        ret = my_file.read()
        my_file.close()
        return ret
    except Exception as error:
        print("line 248")
        print(error)
        return ""

def writeFile(filename, mydata):
    checkPath()
    filename = CONFIGBASE + "/" + filename
    myFile = open(filename, "w")
    myFile.write(str(mydata))
    myFile.close()
    print("Wrote to: " + filename)
    return CONFIGBASE

def checkDB():
    checkPath()
    filename = DBBASE + "/geocaches.db"

    if not os.path.exists(filename):
        conn = sqlite3.connect(filename)
        cursor = conn.cursor()
        cursor.execute("CREATE TABLE IF NOT EXISTS geocaches " +
                       "(cacheid TEXT NOT NULL PRIMARY KEY, " +
                       "dltime INTEGER, cachename TEXT, cacheowner TEXT, " +
                       "cacheurl TEXT, cachesize TEXT, cachetype TEXT, lat REAL, lon REAL, " +
                       "diff REAL, terr REAL, hidden INTEGER, lastfound INTEGER, " +
                       "short TEXT, body TEXT, hint TEXT)")

        cursor.execute("CREATE TABLE IF NOT EXISTS attributes " +
                       "(cacheid TEXT NOT NULL, attribute TEXT NOT NULL)")

        cursor.execute("CREATE TABLE IF NOT EXISTS logbook (cacheid TEXT NOT NULL, " +
                       "logid INTEGER NOT NULL, accountid INTEGER, logtype TEXT, " +
                       "logimage TEXT, logtext TEXT, created INTEGER, visited INTEGER)")

        cursor.execute("CREATE TABLE IF NOT EXISTS users (accountid INTEGER PRIMARY KEY, " +
                       "username TEXT, accountguid TEXT, avatarimage TEXT, findcount INTEGER, " +
                       "hidecount INTEGER)")

        cursor.execute("CREATE TABLE IF NOT EXISTS cacheimages (cacheid TEXT NOT NULL, " +
                       "accountid INTEGER, logid INTEGER, imageid INTEGER PRIMARY KEY, " +
                       "filename TEXT, created INTEGER, name TEXT, descr TEXT)")

        cursor.execute("CREATE INDEX IF NOT EXISTS attributes_cacheid ON attributes(cacheid)")
        cursor.execute("CREATE UNIQUE INDEX IF NOT EXISTS attributes_unique ON " +
                       "attributes(cacheid, attribute)")
        cursor.execute("CREATE INDEX IF NOT EXISTS logbook_cacheid ON logbook(cacheid)")
        cursor.execute("CREATE UNIQUE INDEX IF NOT EXISTS logbook_unique ON " +
                       "logbook(cacheid, logid)")
        cursor.execute("CREATE UNIQUE INDEX IF NOT EXISTS cacheimages_unique ON " +
                       "cacheimages(cacheid, logid, imageid)")
        conn.commit()
        cursor.close()
    else:
        conn = sqlite3.connect(filename)

    return conn

def getRow(conn, cacheid):
    cacheid = cacheid.upper()
    row = geocache.GeoCache()
    cursor = conn.cursor()
    cursor.execute("SELECT * from geocaches where cacheid=?", (cacheid,))
    ret = cursor.fetchone()
    cursor.close()

    if ret != None and ret[0] != "":
        g = geocache.GeoCache()
        g.cacheid = ret[0]
        g.dltime = ret[1]
        g.cachename = ret[2]
        g.cacheowner = ret[3]
        g.cacheurl = ret[4]
        g.cachesize = ret[5]
        g.cachetype = ret[6]
        g.lat = ret[7]
        g.lon = ret[8]
        g.diff = ret[9]
        g.terr = ret[10]
        g.hidden = ret[11]
        g.lastfound = ret[12]
        g.short = ret[13]
        g.body = cacheimages(ret[14])
        g.hint = ret[15].replace("<br>", "\n")
        row = g

    else:
        row = None

    return row

def cacheimage(url, filename):
    if url.startswith("file://") or url.startswith('../assets/notfound.svg'):
        return url

    if url.startswith("/images/icons/"):
        url = "https://www.geocaching.com" + url

    try:
        print(url + " => " + filename)
        if not os.path.exists(filename):
            print(filename + " file doesn't exist, downloading it.")
            res = SESSION.get(url, stream=True)
            if res.status_code == 200:
                with open(filename, 'wb') as f:
                    shutil.copyfileobj(res.raw, f)
            del res

        return "file://" + filename
    except Exception as error:
        print("line 357")
        print(error)

    return "../assets/notfound.svg"

def cacheimages(html):
    data = BeautifulSoup(html, "html.parser")
    for image in data.findAll('img'):
        filename = CACHEBASE + "/" + os.path.basename(image['src']).split("?", 1)[0]
        replacement = cacheimage(image['src'], filename)
        html = html.replace(image['src'], replacement)

    return html

def addToDB(conn, g, attributes):
    cursor = conn.cursor()
    row = getRow(conn, g.cacheid)
    if row != None and row.cacheid != "":
        cursor.execute("UPDATE geocaches set dltime = ?, cachename = ?, cacheowner = ?, " +
                       "cacheurl = ?, cachesize = ?, cachetype = ?, lat = ?, lon = ?, " +
                       "diff = ?, terr = ?, lastfound = ?, short = ?, body = ?, hint = ? " +
                       "WHERE cacheid = ?", (g.dltime, g.cachename, g.cacheowner, g.cacheurl, \
                       g.cachesize, g.cachetype, g.lat, g.lon, g.diff, g.terr, g.lastfound, \
                       g.short, g.body, g.hint, g.cacheid))
    else:
        cursor.execute("INSERT INTO geocaches (cacheid, dltime, cachename, cacheowner, cacheurl, " +
                       "cachesize, cachetype, lat, lon, diff, terr, lastfound, hidden, short, " +
                       "body, hint) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", \
                       (g.cacheid, g.dltime, g.cachename, g.cacheowner, g.cacheurl, \
                       g.cachesize, g.cachetype, g.lat, g.lon, g.diff, g.terr, g.lastfound, \
                       g.hidden, g.short, g.body, g.hint))

    if attributes is not None:
        cursor.execute("DELETE FROM attributes WHERE cacheid = ?", (g.cacheid,))
        for attribute in attributes:
            cursor.execute("INSERT INTO attributes (cacheid, attribute) VALUES (?, ?)", \
                           (g.cacheid, attribute))

    conn.commit()
    cursor.close()

def getAttributes(conn, cacheid):
    cacheid = cacheid.upper()
    attributes = []
    cursor = conn.cursor()

    cursor.execute("SELECT attribute from attributes where cacheid=?", (cacheid,))
    for row in cursor.fetchall():
        attributes.append(row[0])

    cursor.close()
    return attributes

def getJsonAttributes(cacheid):
    cacheid = cacheid.upper()
    conn = checkDB()
    a = getAttributes(conn, cacheid)
    closeDB(conn)

    return json.dumps(a)

def closeDB(conn):
    if conn:
        conn.close()

def cleanUp(var):
    if var == "-":
        var = -1
    else:
        var = time.mktime(datetime.datetime.strptime(var, "%Y-%m-%d").timetuple())
        var = int(var)

    return var

def decdeg2dm(lat, lon):
    lat = float(lat)
    lon = float(lon)

    if lat > 0:
        cardinal_lat = 'N'
    else:
        lat = -lat
        cardinal_lat = 'S'

    if lon > 0:
        cardinal_lon = 'E'
    else:
        lon = -lon
        cardinal_lon = 'W'

    latdeg = int(lat)
    latmin = (lat - int(lat)) * 60

    londeg = int(lon)
    lonmin = (lon - int(lon)) * 60

    loc = "%c+%2d°+%02.3f'+%c+%03d°+%02.3f'" % \
          (cardinal_lat, latdeg, latmin, cardinal_lon, londeg, lonmin)
    return loc

def refreshCache(cacheid):
    cacheid = cacheid.upper()
    conn = checkDB()
    g = getRow(conn, cacheid)

    ret = getCachePage(conn, cacheid, g.cacheurl)
    if ret is None:
        print("Failed to update cache details, are we logged in?")
        return

    lat, lon, short, body, hint, attributes = ret
    dltime = int(time.time())

    g.dltime = dltime
    g.lat = float(lat)
    g.lon = float(lon)
    g.short = short
    g.body = body
    g.hint = hint

    addToDB(conn, g, attributes)

def dlCache(cacheid):
    cacheid = cacheid.upper()
    conn = checkDB()

    cache = getRow(conn, cacheid)
    if cache is None or (cache.lat == 0.0 and cache.lon == 0.0):
        # doesn't exist in the DB, dl and cache it...

        cache_url = "https://www.geocaching.com/geocache/" + cacheid
        print(cache_url)

        try:
            html = SESSION.get(cache_url)
            data = html.text
        except Exception as error:
            print("494 - bombed out, are we still logged in?")
            print(error)
            return "bombed out, are we still logged in?"

        # TODO: check if cache is not found, 404 page doesn't show logged in user menu
        if "li-user-info" not in data:
            print("bombed out, are we still logged in?")
            return "bombed out, are we still logged in?"

        print("Found cacheid: " + cacheid)
        cachename = data.split('<span id="ctl00_ContentBody_CacheName">', 1)[1]
        cachename = cachename.split('</span>', 1)[0].strip()
        cachesize = data.split('" title="Size: ', 1)[1].split(' ', 1)[0].strip()

        cacheowner = data.split('<div id="ctl00_ContentBody_mcd1">', 1)[1]
        cacheowner = cacheowner.split('">', 1)[1].split('</a>', 1)[0].strip()
        cachetype = data.split('<a href="/about/cache_types.aspx" target="_blank" title="', 1)[1]
        cachetype = cachetype.split('"', 1)[0].strip()

        diff = data.split('<span id="ctl00_ContentBody_uxLegendScale" title="', 1)[1]
        diff = diff.split('alt="', 1)[1].split(' ', 1)[0].strip()
        diff = float(diff)
        terr = data.split('<span id="ctl00_ContentBody_Localize12" title="', 1)[1]
        terr = terr.split('alt="', 1)[1].split(' ', 1)[0].strip()
        terr = float(terr)

        hidden = data.split('<div id="ctl00_ContentBody_mcd2">', 1)[1]
        hidden = hidden.split('</div>', 1)[0].split(':', 1)[1].strip()
        hidden = hidden.split('\n', 1)[0].strip()
        hidden = cleanUp(hidden)

        bits = data.split("var lat=", 1)[1].split(", guid='")[0].strip()
        lat = bits.split(", lng=", 1)[0].strip()
        lon = bits.split(", lng=", 1)[1].strip()

        short = data.split('<span id="ctl00_ContentBody_ShortDescription">', 1)[1]
        short = short.split("</span>", 1)[0].strip()

        body = data.split('<span id="ctl00_ContentBody_LongDescription">', 1)[1]
        body = body.split('<p id="ctl00_ContentBody_hints">', 1)[0].strip()
        body = '<span id="ctl00_ContentBody_LongDescription">' + body

        hint = data.split('<div id="div_hint" class="span-8 WrapFix">', 1)[1]
        hint = hint.split('</div>', 1)[0].strip()

        attributes = []

        tmpstr = data.split('<div class="WidgetBody">', 1)[1]
        tmpstr = tmpstr.split('<p class="NoBottomSpacing">', 1)[0]
        for line in tmpstr.split('<img src="/images/attributes/'):
            line = line.strip()
            if line == "":
                continue

            line = line.split('.png"')[0]
            if line == "attribute-blank":
                continue

            attributes.append(line)
            print("attribute == " + line)

        tmpstr = "{" + data.split('initialLogs = {', 1)[1]
        tmpstr = tmpstr.split('};', 1)[0] + "}"
        user_token = data.split("userToken = '", 1)[1].split("';", 1)[0].strip()
        saveLogs(conn, cacheid, tmpstr, user_token)

        cursor = conn.cursor()
        cursor.execute("SELECT visited FROM logbook WHERE cacheid=? and logtype='Found it' " + \
                       "ORDER BY logid DESC LIMIT 1", (cacheid,))
        ret = cursor.fetchone()
        cursor.close()
        if ret is not None:
            lastfound = ret[0]
        else:
            lastfound = -1

        g = geocache.GeoCache()
        g.cacheid = cacheid
        g.dltime = int(time.time())
        g.cachename = cachename
        g.cacheowner = cacheowner
        g.cachesize = cachesize
        g.cacheurl = cache_url
        g.cachetype = cachetype
        g.lat = float(lat)
        g.lon = float(lon)
        g.diff = diff
        g.terr = terr
        g.hidden = hidden
        g.lastfound = lastfound
        g.short = short
        g.body = body
        g.hint = hint

        addToDB(conn, g, attributes)

    closeDB(conn)

    return True

def getCacheList(lat, lon):
    loc = decdeg2dm(lat, lon)
    url = "https://www.geocaching.com/play/search/@" + str(lat) + "," + str(lon) + \
          "?origin=" + loc + "&radius=100km&f=2&o=2&sort=Distance&asc=True"

    print(url)
    conn = checkDB()

    try:
        html = SESSION.get(url)
        data = html.text
    except Exception as error:
        print("606 - bombed out, are we still logged in?")
        print(error)
        return None

    if "li-user-info" not in data:
        print("bombed out, are we still logged in?")
        return None

    data = data.split('<tbody id="geocaches">', 1)[1].split("</tbody>", 1)[0].strip()
    rows = data.split('<tr  data-rownumber="')
    for row in rows:
        row = row.strip()
        if row == "":
            continue

        lat = 0.0
        lon = 0.0
        short = ""
        body = ""
        hint = ""
        dltime = 0

        cacheid = row.split('data-id="', 1)[1].split('"', 1)[0].strip()
        print("Found cacheid: " + cacheid)
        cachename = row.split('data-name="', 1)[1].split('"', 1)[0].strip()
        cachesize = row.split('data-column="ContainerSize">', 1)[1].split('</td>', 1)[0].strip()

        cacheowner = row.split('<span class="owner">', 1)[1].split('</span>', 1)[0].strip()
        cachetype = row.split('<span class="cache-details">', 1)[1].split('|', 1)[0].strip()

        diff = row.split('data-column="Difficulty">', 1)[1].split('</td>', 1)[0].strip()
        diff = float(diff)
        terr = row.split('data-column="Terrain">', 1)[1].split('</td>', 1)[0].strip()
        terr = float(terr)
        hidden = row.split('data-column="PlaceDate">', 1)[1].split('</td>', 1)[0].strip()
        hidden = cleanUp(hidden)
        lastfound = row.split('data-column="DateLastVisited">', 1)[1].split('</td>', 1)[0].strip()
        lastfound = cleanUp(lastfound)
        cacheurl = "https://www.geocaching.com" + row.split('<a href="', 1)[1]
        cacheurl = cacheurl.split('"', 1)[0].strip()

        cache = getRow(conn, cacheid)
        if cache is None or (cache.lat == 0.0 and cache.lon == 0.0):
            ret = getCachePage(conn, cacheid, cacheurl)
            if ret is None:
                print("Failed to update cache details, are we logged in?")
                return

            lat, lon, short, body, hint, attributes = ret
            dltime = int(time.time())
        else:
            print(cacheid + ": Already exists in the db, skipping...")
            lat = cache.lat
            lon = cache.lon
            short = cache.short
            body = cache.body
            hint = cache.hint
            dltime = cache.dltime
            attributes = getAttributes(conn, cacheid)

        g = geocache.GeoCache()
        g.cacheid = cacheid
        g.dltime = dltime
        g.cachename = cachename
        g.cacheowner = cacheowner
        g.cachesize = cachesize
        g.cacheurl = cacheurl
        g.cachetype = cachetype
        g.lat = float(lat)
        g.lon = float(lon)
        g.diff = diff
        g.terr = terr
        g.hidden = hidden
        g.lastfound = lastfound
        g.short = short
        g.body = body
        g.hint = hint

        addToDB(conn, g, attributes)

    closeDB(conn)

def getCachePage(conn, cacheid, url):
    cacheid = cacheid.upper()
    try:
        html = SESSION.get(url)
        data = html.text

        if "li-user-info" not in data:
            print("bombed out, are we still logged in?")
            return None

        bits = data.split("var lat=", 1)[1].split(", guid='")[0].strip()
        lat = bits.split(", lng=", 1)[0].strip()
        lon = bits.split(", lng=", 1)[1].strip()

        short = data.split('<span id="ctl00_ContentBody_ShortDescription">', 1)[1]
        short = short.split("</span>", 1)[0].strip()

        body = data.split('<span id="ctl00_ContentBody_LongDescription">', 1)[1]
        body = body.split('<p id="ctl00_ContentBody_hints">', 1)[0].strip()
        body = '<span id="ctl00_ContentBody_LongDescription">' + body

        hint = data.split('<div id="div_hint" class="span-8 WrapFix">', 1)[1]
        hint = hint.split('</div>', 1)[0].strip()

        attributes = []

        tmpstr = data.split('<div class="WidgetBody">', 1)[1]
        tmpstr = tmpstr.split('<p class="NoBottomSpacing">', 1)[0]
        for line in tmpstr.split('<img src="/images/attributes/'):
            line = line.strip()
            if line == "":
                continue

            line = line.split('.png"')[0]
            if line == "attribute-blank":
                continue

            attributes.append(line)
            print("attribute == " + line)

        tmpstr = "{" + data.split('initialLogs = {', 1)[1]
        tmpstr = tmpstr.split('};', 1)[0] + "}"
        user_token = data.split("userToken = '", 1)[1].split("';", 1)[0].strip()
        saveLogs(conn, cacheid, tmpstr, user_token)

    except Exception as error:
        print("734 - Failed to download cache details, most likely not logged in.")
        print(error)
        return None

    return [float(lat), float(lon), short, body, hint, attributes]

def getMoreLogs(index, size, user_token):
    url = "https://www.geocaching.com/seek/geocache.logbook?tkn=" + user_token + "&idx=" + \
          str(index) + "&num=" + str(size)
    print(url)

    try:
        html = SESSION.get(url)
        data = html.text
        json_object = json.loads(data)
        json_array = json_object['data']
        return json_array
    except Exception as error:
        print("line 752")
        print(error)

    return None

def saveLogs(conn, cacheid, logstr, user_token):
    cacheid = cacheid.upper()
    json_object = json.loads(logstr)
    page_info = json_object['pageInfo']
    # { "idx":1, "size": 25, "totalRows": 151, "rows": 151 }
    size = page_info['size']
    total_rows = page_info['totalRows']
    pages = math.ceil(total_rows / size)
    json_array = json_object['data']

    for i in range(1, pages):
        if i > 1:
            json_array = getMoreLogs(i, size, user_token)
            if json_array is None:
                return

        for log in json_array:
            lb = logbook.LogBook()
            lb.cacheid = cacheid
            lb.logid = log['LogID']
            lb.accountid = log['AccountID']
            lb.logtype = log['LogType']
            lb.logimage = log['LogTypeImage']
            lb.logtext = cacheimages(log['LogText'])
            lb.created = cleanUp(log['Created'])
            lb.visited = cleanUp(log['Visited'])

            saveLog(conn, lb)

            user = users.Users()
            user.accountid = log['AccountID']
            user.username = log['UserName']
            user.accountguid = log['AccountGuid']
            user.avatarimage = log['AvatarImage']
            user.findcount = log['GeocacheFindCount']
            user.hidecount = log['GeocacheHideCount']

            saveUser(conn, user)

            for img in log['Images']:
                image = images.Images()
                image.cacheid = cacheid
                image.accountid = log['AccountID']
                image.imageid = img['ImageID']
                image.logid = log['LogID']
                image.filename = img['FileName']
                image.created = cleanUp(img['Created'])
                image.name = img['Name']
                image.descr = img['Descr']

                saveImage(conn, image)

def saveLog(conn, lb):
    gl = getLog(conn, lb.logid)
    cursor = conn.cursor()
    if gl is None:
        cursor.execute("INSERT INTO logbook (cacheid, logid, accountid, logtype, logimage, " +
                       "logtext, created, visited) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", \
                       (lb.cacheid, lb.logid, lb.accountid, lb.logtype, lb.logimage, lb.logtext, \
                        lb.created, lb.visited))
    else:
        cursor.execute("UPDATE logbook set logtype = ?, logimage = ?, logtext = ?, " +
                       "created = ?, visited = ? WHERE logid = ?", \
                       (lb.logtype, lb.logimage, lb.logtext, lb.created, lb.visited, lb.logid))
    cursor.close()
    conn.commit()

def saveUser(conn, user):
    u = getUser(conn, user.accountid)
    cursor = conn.cursor()
    if u is None:
        cursor.execute("INSERT INTO users (accountid, username, accountguid, avatarimage, " +
                       "findcount, hidecount) VALUES (?, ?, ?, ?, ?, ?)", (user.accountid, \
                       user.username, user.accountguid, user.avatarimage, user.findcount, \
                       user.hidecount))
    else:
        cursor.execute("UPDATE users set username = ?, avatarimage = ?, findcount = ?, " +
                       "hidecount = ? WHERE accountid = ?", \
                       (user.username, user.avatarimage, user.findcount, user.hidecount, \
                        user.accountid))
    cursor.close()
    conn.commit()

def saveImage(conn, image):
    img = getImage(conn, image.imageid)
    if img is None:
        cursor = conn.cursor()
        cursor.execute("INSERT INTO cacheimages (cacheid, accountid, imageid, " +
                       "logid, filename, created, name, descr) VALUES " +
                       "(?, ?, ?, ?, ?, ?, ?, ?)", (image.cacheid, image.accountid, \
                        image.imageid, image.logid, image.filename, image.created, \
                        image.name, image.descr))
        cursor.close()
        conn.commit()

def getImage(conn, imageid):
    cursor = conn.cursor()
    cursor.execute("SELECT * from cacheimages where imageid = ?", (imageid,))
    ret = cursor.fetchone()
    cursor.close()

    if ret != None and ret[0] != "":
        image = images.Images()
        image.cacheid = ret[0]
        image.accountid = ret[1]
        image.imageid = ret[2]
        image.logid = ret[3]
        image.filename = ret[4]
        image.created = ret[5]
        image.name = ret[6]
        image.descr = ret[7]
        row = image

    else:
        row = None

    return row

def getImages(conn, logid):
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM cacheimages where logid = ?", (logid,))

    arr = []
    for row in cursor:
        output = {}
        output['cacheid'] = row[0]
        output['accountid'] = row[1]
        output['imageid'] = row[2]
        output['logid'] = row[3]
        url = "https://img.geocaching.com/cache/log/large/" + row[4]
        filename = cacheimage(url, CACHEBASE + "/" + row[4])
        output['filename'] = filename
        output['created'] = row[5]
        output['name'] = row[6]
        output['descr'] = row[7]
        arr.append(output)

    return arr

def getJsonUser(accountid):
    conn = checkDB()
    u = getUser(conn, accountid)
    closeDB(conn)

    return str(u)

def getJsonLogs(cacheid):
    cacheid = cacheid.upper()
    conn = checkDB()
    a = getLogs(conn, cacheid)
    closeDB(conn)

    return a

def getLogs(conn, cacheid):
    cacheid = cacheid.upper()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM logbook, users where logbook.accountid = users.accountid and " +
                   "cacheid = ? ORDER BY logid DESC", (cacheid,))

    gArr = "["
    for row in cursor:
        output = {}
        output['cacheid'] = row[0]
        output['logid'] = row[1]
        output['accountid'] = row[2]
        output['logtype'] = row[3]
        output['logimage'] = row[4]
        output['logtext'] = cacheimages(row[5])
        output['created'] = datetime.datetime.fromtimestamp(row[6]).strftime('%Y-%m-%d')
        output['visited'] = datetime.datetime.fromtimestamp(row[7]).strftime('%Y-%m-%d')
        output['accountid'] = row[8]
        output['username'] = row[9]
        output['accountguid'] = row[10]
        output['avatarimage'] = row[11]
        output['findcount'] = row[12]
        output['hidecount'] = row[13]
        output['images'] = getImages(conn, row[1])

        gArr += json.dumps(output) + ","

    cursor.close()
    closeDB(conn)

    if gArr[-1:] == ",":
        gArr = gArr[:-1]
    gArr += "]"

    return gArr

def getUser(conn, accountid):
    cursor = conn.cursor()
    cursor.execute("SELECT * from users where accountid = ?", (accountid,))
    ret = cursor.fetchone()
    cursor.close()

    if ret != None and ret[0] != "":
        user = users.Users()
        user.accountid = ret[0]
        user.username = ret[1]
        user.accountguid = ret[2]
        user.avatarimage = ret[3]
        user.findcount = ret[4]
        user.hidecount = ret[5]
        row = user

    else:
        row = None

    return row

def getLog(conn, logid):
    cursor = conn.cursor()
    cursor.execute("SELECT * from logbook where logid = ?", (logid,))
    ret = cursor.fetchone()
    cursor.close()

    if ret != None and ret[0] != "":
        lb = logbook.LogBook()
        lb.cacheid = ret[0]
        lb.logid = ret[1]
        lb.accountid = ret[2]
        lb.logtype = ret[3]
        lb.logimage = ret[4]
        lb.logtext = cacheimages(ret[5])
        lb.created = ret[6]
        lb.visited = ret[7]
        row = lb

    else:
        row = None

    return row

def switchem(from_ll, to_ll):
    tmp = from_ll
    from_ll = to_ll
    to_ll = tmp
    return from_ll, to_ll

def getMarkers():
    conn = checkDB()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM geocaches")

    startcol = -1

    gArr = "["
    for row in cursor:
        html = HTMLParser()
        g = geocache.GeoCache()
        # print(row[startcol + 1])
        g.cacheid = row[startcol + 1]
        g.dltime = int(time.time()) - int(row[startcol + 2])
        g.cachename = html.unescape(row[startcol + 3])
        g.cacheowner = row[startcol + 4]
        g.cacheurl = row[startcol + 5]
        g.cachesize = row[startcol + 6]
        g.cachetype = row[startcol + 7]
        g.lat = row[startcol + 8]
        g.lon = row[startcol + 9]
        g.diff = row[startcol + 10]
        g.terr = row[startcol + 11]
        g.hidden = row[startcol + 12]
        g.lastfound = row[startcol + 13]
        g.short = "" #row[startcol + 14]
        g.body = "" #row[startcol + 15]
        g.hint = "" #row[startcol + 16]
        gArr += str(g) + ","

    cursor.close()
    closeDB(conn)

    if gArr[-1:] == ",":
        gArr = gArr[:-1]
    gArr += "]"

    return gArr

def getJsonRow(cacheid):
    cacheid = cacheid.upper()
    conn = checkDB()
    g = getRow(conn, cacheid)
    closeDB(conn)

    if g == None:
        return "{}"

    html = HTMLParser()
    g.cachename = html.unescape(g.cachename)
    g.dltime = int(time.time()) - int(g.dltime)
    g.body = remove_all_attrs_except(g.body)

    return str(g)

def strip_html(src):
    p = BeautifulSoup(src, "html.parser")
    text = p.findAll(text=lambda text: isinstance(text, NavigableString))

    return u" ".join(text)

def remove_all_attrs_except(soup):
    whitelist = ['a', 'img', 'br', 'p'] #, 'span', 'strong', 'em', 'font']
    soup = BeautifulSoup(soup, "html.parser")
    for tag in soup.find_all(True):
        if tag.name not in whitelist:
            tag.hidden = True
    soup = str(soup)
    return soup
