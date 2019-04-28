#!/usr/bin/python3

""" file functions wrapper """

import os
import pickle
import shutil
import requests

APP_ID = os.environ.get("APP_ID", "").split('_')[0]
CONFIGBASE = os.environ.get("XDG_CONFIG_HOME", "/tmp") + "/" + APP_ID
CACHEBASE = os.environ.get("XDG_CACHE_HOME", "/tmp") + "/" + APP_ID

HEADERS = {}
HEADERS['User-Agent'] = "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 "
HEADERS['User-Agent'] += "(KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"

def check_paths():
    """ check and make directories as needed. """

    os.makedirs(CONFIGBASE, exist_ok=True)
    os.makedirs(CACHEBASE, exist_ok=True)

def get_session():
    """ Load http session """

    check_paths()

    print("Attempting to reload the previous session.")

    try:
        filename = CONFIGBASE + "/session.bin"
        with open(filename, 'rb') as file:
            session = pickle.load(file)

        session.headers = HEADERS
        print("Session re-loaded.")
    except Exception as error:
        print("line 39 - Failed to load session, see below for trace.")
        print(error)
        session = requests.Session()
        session.headers = HEADERS

    return session

def save_session(session):
    """ Save session to filesystem """

    check_paths()

    print("Attempting to save the session.")

    try:
        filename = CONFIGBASE + "/session.bin"
        with open(filename, 'wb') as file:
            pickle.dump(session, file)
        print("Session saved.")
    except Exception as error:
        print("line 59 - Failed to save session, see below for trace.")
        print(error)

def get_auth():
    """ Load auth details from geocaching.ini """

    username = ""
    password = ""

    data = read_file("geocaching.ini")
    for line in data.split("\n"):
        if line.split("=", 1)[0] == "username":
            username = line.split("=", 1)[1]
        if line.split("=", 1)[0] == "password":
            password = line.split("=", 1)[1]

    return [username, password]

def read_file(filename):
    """ Read content from a file """

    check_paths()

    try:
        filename = CONFIGBASE + "/" + filename
        my_file = open(filename, "r+")
        ret = my_file.read()
        my_file.close()
        return ret
    except Exception as error:
        print("line 94")
        print(error)

    return ""

def write_file(filename, mydata):
    """ save data to a file """

    check_paths()
    filename = CONFIGBASE + "/" + filename
    my_file = open(filename, "w")
    my_file.write(str(mydata))
    my_file.close()
    print("Wrote to: " + filename)
    return CONFIGBASE

def cache_image(url, session):
    """ check to see if a file is cached, otherwise download and save to a file """

    if url.startswith("file://") or url.startswith('../assets/notfound.svg'):
        return url

    if url.startswith("/images/"):
        url = "https://www.geocaching.com" + url

    filename = CACHEBASE + "/" + os.path.basename(url).split("?", 1)[0].split('#', 1)[0].strip()

    try:
        print(url + " => " + filename)
        if not os.path.exists(filename):
            print(filename + " file doesn't exist, downloading it.")
            res = session.get(url, stream=True)
            if res.status_code == 200:
                with open(filename, 'wb') as file:
                    shutil.copyfileobj(res.raw, file)

        return "file://" + filename
    except Exception as error:
        print("line 129")
        print(error)

    return "../assets/notfound.svg"
