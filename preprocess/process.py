#!/usr/bin/env python
from __future__ import print_function
import fileinput
import re

p = re.compile('^(?P<comm>#+\ *)?(?P<prop>[^\s]+) = (?P<val>.+)')
cp = re.compile('^#+(?P<comm>.+)')

def process(m):
    comm = m.group('comm')
    prop = m.group('prop')
    gprop = '.' + prop.upper().replace('.', '__').replace('$', '_')
    val = m.group('val')
    ip = ''
    bi = '{}'
    ei = ''
    if comm:
        ip = gprop
        bi = '{{{{if {} }}}}'
        ei = '{{{{end}}}}'

    return (bi + '{} = {{{{ or {} "{}" }}}}' + ei).format(
        ip, prop, gprop, val)

for line in fileinput.input():
    if line == '\n':
        print('')
        continue

    cm = cp.match(line)
    m = p.match(line)

    if m:
        print(process(m), end='')
    elif cm:
        co = '{{/*'
        cc = ' */}}'
        print(co, cm.group('comm'), cc, end='')

    print()
