---
allowed-tools: Bash(python3:*), Bash(python:*), Read, Write, Grep, Glob, Agent
description: Parse .mbox Gmail exports — index messages, extract attachments, search by sender/subject/date
---

# Mbox Parser

Parse Gmail .mbox export files to index messages, extract attachments, and search for evidence.

## Arguments

The user provides one of:
- A path to an .mbox file (e.g., `/mbox-parse C:/Users/atayl/Desktop/All mail Including Spam and Trash.mbox`)
- A command: `index`, `search <term>`, `extract <message_id>`, `attachments`, `stats`

## Default .mbox Location

If no path given, look for `.mbox` files on Desktop:
```
C:/Users/atayl/Desktop/*.mbox
```

## Commands

### `index` (default if just a path is given)
Parse the entire .mbox and write a structured index:

```python
python3 -c "
import mailbox
import email
import email.utils
import json
import os
import sys
from datetime import datetime

mbox_path = sys.argv[1] if len(sys.argv) > 1 else None
if not mbox_path:
    import glob
    candidates = glob.glob(r'C:\Users\atayl\Desktop\*.mbox')
    if candidates:
        mbox_path = max(candidates, key=os.path.getsize)
    else:
        print('No .mbox file found on Desktop')
        sys.exit(1)

print(f'Parsing: {mbox_path} ({os.path.getsize(mbox_path) / 1024 / 1024:.1f} MB)')

mbox = mailbox.mbox(mbox_path)
messages = []
attachment_count = 0

for i, msg in enumerate(mbox):
    date_str = msg.get('Date', '')
    subject = msg.get('Subject', '(no subject)')
    from_addr = msg.get('From', '')
    to_addr = msg.get('To', '')
    msg_id = msg.get('Message-ID', f'msg-{i}')

    # Count attachments
    atts = []
    if msg.is_multipart():
        for part in msg.walk():
            fn = part.get_filename()
            if fn:
                atts.append(fn)
                attachment_count += 1

    messages.append({
        'index': i,
        'date': date_str,
        'subject': subject[:200],
        'from': from_addr[:100],
        'to': to_addr[:100],
        'attachments': atts,
        'message_id': msg_id,
    })

    if (i + 1) % 500 == 0:
        print(f'  ...parsed {i+1} messages')

print(f'Total: {len(messages)} messages, {attachment_count} attachments')

# Write index
out_dir = os.path.dirname(mbox_path)
index_path = os.path.join(out_dir, 'mbox_index.json')
with open(index_path, 'w', encoding='utf-8') as f:
    json.dump(messages, f, indent=1, ensure_ascii=False)
print(f'Index written to: {index_path}')

# Write human-readable summary
summary_path = os.path.join(out_dir, 'mbox_summary.md')
with open(summary_path, 'w', encoding='utf-8') as f:
    f.write(f'# Mbox Summary\\n\\n')
    f.write(f'- **File**: {os.path.basename(mbox_path)}\\n')
    f.write(f'- **Size**: {os.path.getsize(mbox_path) / 1024 / 1024:.1f} MB\\n')
    f.write(f'- **Messages**: {len(messages)}\\n')
    f.write(f'- **Attachments**: {attachment_count}\\n\\n')
    f.write('## Messages with Attachments\\n\\n')
    for m in messages:
        if m['attachments']:
            f.write(f\"\"\"- **{m['index']}** | {m['date'][:16]} | {m['subject'][:80]}\\n\"\"\")
            for a in m['attachments']:
                f.write(f'  - {a}\\n')
print(f'Summary written to: {summary_path}')
" "$1"
```

### `search <term>`
Search the index for messages matching a term (subject, from, to):

```python
python3 -c "
import json, sys
term = ' '.join(sys.argv[1:]).lower()
with open(r'C:\Users\atayl\Desktop\mbox_index.json') as f:
    messages = json.load(f)
hits = [m for m in messages if term in m['subject'].lower() or term in m['from'].lower() or term in m['to'].lower()]
print(f'{len(hits)} matches for \"{term}\":')
for m in hits[:50]:
    atts = f' [{len(m[\"attachments\"])} att]' if m['attachments'] else ''
    print(f'  #{m[\"index\"]} | {m[\"date\"][:16]} | {m[\"from\"][:40]} | {m[\"subject\"][:60]}{atts}')
" SEARCH_TERM
```

### `extract <index_number>`
Extract a specific message and its attachments:

```python
python3 -c "
import mailbox, os, sys, email

idx = int(sys.argv[1])
import glob
mbox_path = max(glob.glob(r'C:\Users\atayl\Desktop\*.mbox'), key=os.path.getsize)
mbox = mailbox.mbox(mbox_path)

for i, msg in enumerate(mbox):
    if i == idx:
        print(f'Subject: {msg[\"Subject\"]}')
        print(f'From: {msg[\"From\"]}')
        print(f'To: {msg[\"To\"]}')
        print(f'Date: {msg[\"Date\"]}')
        print('---')

        # Print body
        if msg.is_multipart():
            for part in msg.walk():
                ct = part.get_content_type()
                fn = part.get_filename()
                if fn:
                    out_dir = r'C:\Users\atayl\Desktop\mbox_attachments'
                    os.makedirs(out_dir, exist_ok=True)
                    out_path = os.path.join(out_dir, fn)
                    with open(out_path, 'wb') as f:
                        f.write(part.get_payload(decode=True) or b'')
                    print(f'ATTACHMENT SAVED: {out_path}')
                elif ct == 'text/plain':
                    body = part.get_payload(decode=True)
                    if body:
                        print(body.decode('utf-8', errors='replace')[:5000])
        else:
            body = msg.get_payload(decode=True)
            if body:
                print(body.decode('utf-8', errors='replace')[:5000])
        break
" INDEX_NUMBER
```

### `attachments`
List all messages that have attachments, grouped by file type.

### `stats`
Show date range, top senders, top recipients, messages per month histogram.

## Output

- `mbox_index.json` — machine-readable index of all messages
- `mbox_summary.md` — human-readable summary with attachment inventory
- `mbox_attachments/` — extracted attachment files

## Important Notes

- Large .mbox files (100MB+) may take 30-60 seconds to parse. Use `timeout: 120000` for the Bash call.
- The index is cached after first parse — subsequent searches use the JSON index, not the raw .mbox.
- For case evidence: after indexing, search for key names (Wheeler, Campbell, Wiley, Wareham, Tolin, Ko) and key subjects (IG, QAI, SAPR, clearance, MEB).
