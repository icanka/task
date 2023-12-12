#!/bin/sh

# multiline constant text, example of output of `who` command
users="
user1 pts/0        2023-12-11 17:56 (:0)
user1 pts/0        2023-12-11 17:56 (:0)
user2 pts/1        2023-12-11 17:56 (:0)
user3 pts/2        2023-12-11 17:56 (:0)
user4 pts/4        2023-12-11 17:56 (:0)
"

#logged_in_users="$(echo "${users}" | awk 'NF {print $1}' | sort | uniq)"
logged_in_users="$(who | awk 'NF {print $1}' | sort | uniq)"

# create users.txt if it does not exist
if [ ! -f users.txt ];then
    # use absolute path
    touch /tmp/users.txt
fi

# add logged in users to users.txt if they are not already there
while read -r user; do
    if ! grep -q "${user}" /tmp/users.txt; then
        echo "${user}" >> /tmp/users.txt
    fi
done << EOF 
${logged_in_users}
EOF
