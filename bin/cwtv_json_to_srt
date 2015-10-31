#!/usr/bin/env python3
# encoding: utf-8

'''
This script will convert a close captioning subtitle .json file as found on the
CWTV streaming website, to a regular .srt for use in common media players.

.json example:

{
    "endTime": 10.04,
    "guid": "ffffffff-0000-1111-2222-aaaaaaaaaaaa",
    "hitType": "tag",
    "id": "abc123abc123abc123abc123",
    "metadata": {
        "ID": "",
        "Language": "en",
        "Text": "All that glitters"
    },
    "segmentTypeId": "abc123abc123abc123abc123",
    "startTime": 1.002999,
    "subTrack": null,
    "tags": [],
    "track": "Closed Captioning"
}

.srt example:

1
00:00:10,500 --> 00:00:13,000
All that glitters

'''

from __future__ import print_function
import json
import sys


def seconds_to_hms(seconds):
    whole_seconds, microseconds = str(seconds).split('.')
    whole_seconds = int(whole_seconds)

    # The seconds part is just an int, but we need to turn the microseconds part
    # into milliseconds. Subtracting seconds from this value will give us a
    # float between 0.000000 and 0.999999, and multiplying that by a million is
    # the number of microseconds as an int, from which we can have milliseconds.
    microseconds = int((float(seconds) - whole_seconds) * 1000000)
    milliseconds = int(microseconds / 1000) + whole_seconds * 1000

    seconds, milliseconds = divmod(milliseconds, 1000)
    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)

    return '{:02d}:{:02d}:{:02d},{}'.format(hours, minutes, seconds,
                                            str(milliseconds * 10).ljust(3, '0'))

if len(sys.argv) != 2:
    print('You must provide a .json input file.')
    sys.exit(1)

with open(sys.argv[1], 'rU') as f:
    for index, item in enumerate(json.load(f)):
        text = item['metadata']['Text']
        start = seconds_to_hms(item['startTime'])
        end = seconds_to_hms(item['endTime'])
        print('{}\n{} --> {}\n{}\n'.format(index + 1, start, end, text))
