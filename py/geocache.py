#!/usr/bin/python3

"""blah!"""

import json

class GeoCache(object):
    """ Store cache details in a class """

    cacheid = ""
    dltime = 0
    cachename = ""
    cacheowner = ""
    cacheurl = ""
    cachesize = ""
    cachetype = ""
    lat = ""
    lon = ""
    diff = 0.0
    terr = 0.0
    hidden = 0
    lastfound = 0
    short = ""
    body = ""
    hint = ""
    found = 0

    def __init__(self):
        pass

    def __str__(self):

        output = {}
        output['cacheid'] = self.cacheid
        output['dltime'] = self.dltime
        output['cachename'] = self.cachename
        output['cacheowner'] = self.cacheowner
        output['cacheurl'] = self.cacheurl
        output['cachesize'] = self.cachesize
        output['cachetype'] = self.cachetype
        output['lat'] = self.lat
        output['lon'] = self.lon
        output['diff'] = self.diff
        output['terr'] = self.terr
        output['hidden'] = self.hidden
        output['lastfound'] = self.lastfound
        output['short'] = self.short
        output['body'] = self.body
        output['hint'] = self.hint
        output['found'] = self.found

        return json.dumps(output)

    # from_lat = lat - 1
    # to_lat = lat + 1
    # from_lon = lon - 1
    # to_lon = lon + 1

    # if from_lat > to_lat:
    #     from_lat, to_lat = switchem(from_lat, to_lat)
    # if from_lon > to_lon:
    #     from_lon, to_lon = switchem(from_lon, to_lon)

    # cursor.execute("SELECT ABS(? - lat) * ABS(? - lat) + ABS(? - lon) * ABS(? - lon) " +
    #                 "AS distance, * FROM geocaches", (lat, lat, lon, lon)) \
    #                where lat between ? and ? and lon " + \
    #                "between ? and ? ORDER BY distance ASC limit 20", \
    #                (lat, lat, lon, lon, from_lat, to_lat, from_lon, to_lon))

   # if "*" in var:
    #     var = var.split("*", 1)[0]

    # var = var.strip()

    # print("var == " + var)

    # if var == "":
    #     var = -1
    # elif var == "Today":
    #     var = time.time()
    # elif var == "Yesterday":
    #     var = time.time() - 86400
    # elif var == "2 days ago":
    #     var = time.time() - 86400 * 2
    # elif var == "3 days ago":
    #     var = time.time() - 86400 * 3
    # elif var == "4 days ago":
    #     var = time.time() - 86400 * 4
    # elif var == "5 days ago":
    #     var = time.time() - 86400 * 5
    # elif var == "6 days ago":
    #     var = time.time() - 86400 * 6
    # elif var == "7 days ago":
    #     var = time.time() - 86400 * 7
    # else:

# def getCacheList(lat, lon, found=1):
#     conn = checkDB()

#     url = "https://www.geocaching.com/seek/nearest.aspx?lat=" + str(lat) + "&lng=" + str(lon)
#     url += "&f=" + str(found)

#     print(url)

#     # url = "http://192.168.2.10/nearest.html"

#     html = SESSION.get(url)

#     data = html.text

#     try:
#         data = data.split('<tr class="SolidRow Data BorderTop">', 1)[1].split("</table>", 1)[0]
#     except:
#         return None

#     rows = data.split("<tr class=")
#     for row in rows:
#         lat = 0.0
#         lon = 0.0
#         short = ""
#         body = ""
#         hint = ""

#         cacheurl = row.split('<td class="Merge">', 1)[1].split('<a href="', 1)[1].split('"', 1)[0]
#         img = row.split('<img src="/images/WptTypes/', 1)[1].split('"', 1)[0]

#         cachetype = row.split('<img src="/images/WptTypes/', 1)[1]
#         cachetype = cachetype.split('" title="', 1)[1].split('"', 1)[0]

#         cachename = row.split("<span>", 1)[1].split("</span>", 1)[0].strip()

#         cacheowner = row.split('<span class="small">', 1)[1].split("|", 1)[0].strip()
#         cacheid = row.split("|", 2)[1].strip()

#         bits = row.split('<td class="AlignCenter">', 1)[1].strip()
#         bits = bits.split('<span class="small">')

#         bit = bits[1]
#         cachediff, cacheterr = bit.split("</span>", 1)[0].split("/")

#         bit = bits[2]
#         hidden = bit.split("</span>", 1)[0].strip()

#         bit = bits[3]
#         lastfound = bit.split("</span>", 1)[0].strip()

#         hidden = cleanUp(hidden)
#         lastfound = cleanUp(lastfound)

#         cache = getRow(conn, cacheid)
#         if cache == None or cache.lat == 0.0:
#             print(cacheid)
#             lat, lon, short, body, hint = getCachePage(cacheurl)

#         g = geocache.GeoCache()
#         g.cacheid = cacheid
#         g.dltime = int(time.time())
#         g.cachename = cachename
#         g.cacheowner = cacheowner
#         g.cacheurl = cacheurl
#         g.cacheimg = img
#         g.cachetype = cachetype
#         g.lat = float(lat)
#         g.lon = float(lon)
#         g.diff = float(cachediff)
#         g.terr = float(cacheterr)
#         g.hidden = hidden
#         g.lastfound = lastfound
#         g.short = short
#         g.body = body
#         g.hint = hint

#         addToDB(conn, g)

#     closeDB(conn)
