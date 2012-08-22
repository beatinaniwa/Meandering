import json
import sys

content = open(sys.argv[1]).read()
timeEntries = json.loads(content)
timeList = []
for entry in timeEntries:
    for key in entry:
        timeList.append(int(entry[key]))

timeList.sort()
for time in timeList:
    print time
