= Setup PostgreSQL

== with ansible (not finished yet)

1. pipenv install
2. pipenv shell
3. ansible-galaxy install -r requirements.yml
4. ansible-playbook postgresql.yml --ask-become-pass

== Classico


.(postgresql) create role and databases
[source,sh]
----
createuser -D -E -S -R -W cocard
createdb -O cocard cocard_development --lc-collate=de_DE.UTF-8 --lc-ctype=de_DE.UTF-8
createdb -O cocard cocard_test --lc-collate=de_DE.UTF-8 --lc-ctype=de_DE.UTF-8
----

.(postgresql) Set password
[source,sql]
----
ALTER USER cocard WITH PASSWORD '******';
----

