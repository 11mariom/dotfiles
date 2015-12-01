#!/usr/bin/env python

import imaplib
import netrc
import argparse

def auth(mail):
    try:
        info = netrc.netrc()
    except:
        print "No ~/.netrc file!"
        exit(1)

    try:
        login, account, password = info.authenticators(mail)
    except:
        print "No entry for " + mail + " in netrc file!"
        exit(1)

    return login, password

def login(mail, ssl = False):
    login, password = auth(mail)

    if ssl:
        server = imaplib.IMAP4_SSL(mail, 993)
    else:
        server = imaplib.IMAP4(mail, 143)
    server.login(login, password)

    return server

def logout(server):
    server.logout()

def unread(server, folder = None):
    if folder:
        server.select(folder)
    else:
        server.select()
    status, ids = server.search(None, "UnSeen")
    return len(ids[0].split())
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ssl", "-s", action="store_true", default=False,
                        help="Use ssl")
    parser.add_argument("--folder", "-f", default=None,
                        help="Folder to check, default all")
    parser.add_argument('mail', metavar='mail',
                        help='Mail server')
    args = parser.parse_args()

    conn = login(args.mail, args.ssl)

    print unread(conn, args.folder)
    logout(conn)
