HeidiSQL execution steps for questgiver fix script

1) In HeidiSQL, use: File -> Load SQL file...
2) Open this exact file from your repo:
   sql/RoleplayCore/5. questgiver consistency fix.sql
3) Execute the loaded SQL tab.

Do NOT paste a git diff/patch into HeidiSQL.
If the text contains lines like these, stop immediately (this is NOT SQL):
- diff --git ...
- --- /dev/null
- +USE `world`;

If you see leading '+' characters before SQL statements, you are running diff output, not raw SQL.
