#!/usr/bin/env bash

DATE=$(date)
COMMIT=${COMMIT:-}
MESSAGE=${MESSAGE:-}
GITHUB_RUN_ID=${GITHUB_RUN_ID:-}
FAILED_JOBS=${FAILED_JOBS:-}

# Parse failed jobs from JSON
get_failed_jobs() {
  if [ -n "$FAILED_JOBS" ]; then
    echo "$FAILED_JOBS" | jq -r 'to_entries[] | select(.value.result == "failure") | .key' | tr '\n' ', ' | sed 's/,$//'
  else
    echo "Unknown"
  fi
}

FAILED_JOB_NAMES=$(get_failed_jobs)

generate_json() {
  cat << EOF
{
  "msg_type": "interactive",
  "card": {
    "config": {
      "wide_screen_mode": true
    },
    "elements": [
      {
        "fields": [
          {
            "is_short": true,
            "text": {
              "content": "**Date**\n${DATE}",
              "tag": "lark_md"
            }
          },
          {
            "is_short": true,
            "text": {
              "content": "**Version**\n${VERSION}",
              "tag": "lark_md"
            }
          }
        ],
        "tag": "div"
      },
      {
        "fields": [
          {
            "is_short": false,
            "text": {
              "content": "**Failed Jobs**\n${FAILED_JOB_NAMES}",
              "tag": "lark_md"
            }
          }
        ],
        "tag": "div"
      },
      {
        "fields": [
          {
            "is_short": false,
            "text": {
              "content": "**Commit Message**\n${MESSAGE}",
              "tag": "lark_md"
            }
          }
        ],
        "tag": "div"
      },
      {
        "actions": [
          {
            "tag": "button",
            "text": {
              "content": "View Logs",
              "tag": "plain_text"
            },
            "type": "danger",
            "url": "https://github.com/cicloud/cicloud.github.io/actions/runs/${GITHUB_RUN_ID}"
          }
        ],
        "tag": "action"
      }
    ],
    "header": {
      "template": "red",
      "title": {
        "content": "[Build Failed] Optical",
        "tag": "plain_text"
      }
    }
  }
}
EOF
}

generate_json