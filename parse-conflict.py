#!/usr/bin/env python3

from thefuzz import fuzz
from sys import argv

head_lines = []
incoming_lines = []
parent_lines = []

counting = 0 # 1 - counting HEAD, 2 - counting incoming strings, 3 - counting incoming's parent
hunk_num = -1
hunk_meta = ""
with open(argv[1], "r") as pf:
    for line in pf:
        if line.startswith("@@@"):
            hunk_meta = line
            hunk_num += 1
            head_lines.append("")
            incoming_lines.append("")
        if line.startswith('++<<<'):
            counting = 1
            continue
        elif line.startswith("++==="):
            counting = 2
            continue
        elif line.startswith("++|||"):
            counting = 3
            continue
        elif line.startswith("++>>>"):
            if counting != 0:
                print(hunk_meta)
                print(fuzz.ratio(head_lines[hunk_num], incoming_lines[hunk_num]))
            counting = 0
            continue
        
        if counting == 1:
            head_lines[hunk_num] = f"{head_lines[hunk_num]}{line[1:].lstrip()}"
        elif counting == 2:
            incoming_lines[hunk_num] = f"{incoming_lines[hunk_num]}{line[1:].lstrip()}"
        elif counting == 3:
            parent_lines[hunk_num] = f"{parent_lines[hunk_num]}{line[1:].lstrip()}"
        else:
            continue
        



# print(head_lines)
# print()
# print(incoming_lines)

# for i in range(len(head_lines)):
#     print(fuzz.ratio(head_lines[i], incoming_lines[i]))
