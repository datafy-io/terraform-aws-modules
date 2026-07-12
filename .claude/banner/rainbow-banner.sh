#!/usr/bin/env bash
# Reads banner.txt and emits it as a JSON {systemMessage: ...} with a
# per-column 24-bit-ANSI rainbow gradient. Used by the SessionStart hook.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

colored="$(awk '
function hsv(h,   r,g,b,i,f,p,q,t) {
  # full saturation/value rainbow; h in [0,360)
  i = int(h/60) % 6
  f = h/60 - int(h/60)
  p = 0; q = 255*(1-f); t = 255*f
  if (i==0) { r=255; g=t;   b=p   }
  else if (i==1) { r=q;   g=255; b=p   }
  else if (i==2) { r=p;   g=255; b=t   }
  else if (i==3) { r=p;   g=q;   b=255 }
  else if (i==4) { r=t;   g=p;   b=255 }
  else           { r=255; g=p;   b=q   }
  return sprintf("%d;%d;%d", r, g, b)
}
{
  n = length($0)
  if (n > max) max = n
  lines[NR] = $0
}
END {
  esc = sprintf("%c[", 27)
  bands = 8             # number of distinct color steps across the widest line
                        # (kept low so the JSON stays small enough to render inline)
  for (ln = 1; ln <= NR; ln++) {
    s = lines[ln]
    out = ""
    prev = ""
    L = length(s)
    for (c = 1; c <= L; c++) {
      band = (max > 1) ? int((c-1) * bands / max) : 0
      hue  = (bands > 1) ? (300 * band / (bands-1)) : 0
      col  = hsv(hue)
      if (col != prev) { out = out esc "38;2;" col "m"; prev = col }
      out = out substr(s, c, 1)
    }
    printf "%s%s%sm\n", out, esc, "0"
  }
}
' "$dir/banner.txt")"

printf '%s' "$colored" | jq -Rs '{systemMessage: .}'
