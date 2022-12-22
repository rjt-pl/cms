#!/usr/bin/env python3

# standings.py - CMS iRacing Standings fetcher
#
# This does little more than download the standings spreadsheet
# and output those sheets in JSON format. Idea being, to decouple
# the Sheets interface (logically and physically) from the two
# different servers this will run on.
#
# 2022 Ryan Thompson <i@ry.ca>

from __future__ import print_function

import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
import json

SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']

# Spreadsheet ID is in the URL when viewing normally
SHEET_ID = '1eSOaIjffxW7G8NLP_xoWYuleMRUpmCkoqvF3MwI5Ulw'
CREDS_FILE = 'token.json' # Get from Google OAuth2 API
# Sheets and ranges we need
RANGES = ['Results!A:D',
           'Config!A:C',
          'Drivers!A:D',
           'Points!A:E',
            'Races!A:C']

# Range syntax: Sheet Name!A:D to get first four columns
# Can also use: Sheet Name!A2:A4 to get a range


# Create credentials file
def create_creds(creds):
    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
    else:
        flow = InstalledAppFlow.from_client_secrets_file(
            'client_secret.json', SCOPES)
        creds = flow.run_local_server(port=0)

    # Save the credentials for the next run
    with open(CREDS_FILE, 'w') as token:
        token.write(creds.to_json())

    return(creds)


def main():
    creds = None
    if os.path.exists(CREDS_FILE):
        creds = Credentials.from_authorized_user_file(CREDS_FILE, SCOPES);
    if not creds or not creds.valid:
        creds = create_creds(creds)

    try:
        service = build('sheets', 'v4', credentials = creds)

        sheet = service.spreadsheets()
        result = sheet.values().batchGet(spreadsheetId=SHEET_ID,
                                    ranges=RANGES).execute()

        #for range in result['valueRanges']:
        #    values = range.get('values', [])

        print(json.dumps(result)) # JSON

    except HttpError as err:
        print(err)

if __name__ == '__main__':
    main()

