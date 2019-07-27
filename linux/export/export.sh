#!/bin/bash

layout='us'
variant='qwerty-fr'

setxkbmap "$layout" "$variant" -print | xkbcomp -xkm - "$layout_$variant.xkm"
setxkbmap "$layout" "$variant" -print | xkbcomp -C - "$layout_$variant.h"

