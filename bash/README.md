# health_check.sh

A portable system health monitoring script for Linux.

## What it does
Checks disk usage, memory usage, and CPU load against defined thresholds
and reports OK / WARNING / CRITICAL for each.

## Usage
```bash
chmod +x health_check.sh
./health_check.sh
```

## Checks
| Check | Warning | Critical |
|-------|---------|----------|
| Disk  | ≥60%    | ≥80%     |
| Memory| ≥70%    | ≥90%     |
| CPU   | ≥2.0    | ≥4.0     |

## Exit Codes
| Code | Meaning  |
|------|----------|
| 0    | All OK   |
| 1    | Warning  |
| 2    | Critical |

## Log file
Appends to `/tmp/health_check.log` on every run.
